eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
	if 0;
my $pname = $0; $pname =~ s/.*\/(.*)/$1/s; # プログラム名取得
#
# バケット送信処理
#
# send-bucket.pl
#

use strict;
use vars qw/$opt_d/;
use vars qw/$BucketDir $RecvDir $TarFileName $LockFile $MaxRetryCnt/;

use POSIX 'strftime';
use Getopt::Std;
use Net::FTP;
use Cwd;

my $debug = 0;
getopts('d');
if ( $opt_d ) { $debug = 1; }

# コンフィグレーションの設定
require "./conf.pl";

# syslogモジュール
require "./logpkg.pl";

# グローバル変数
my $cur_dir = Cwd::cwd();	# カレントディレクトリ
my $snd_bucket = "";
my $ctrl_file = "";
my $snd_host = "webopac";
my $ftp_user = "ftpenju";
my $ftp_pass = "gota2k12nda";
my $exec_date = "";
my $send_stat = "";
my $rtry_cnt = 0;

# 引数のチェック
my $opt = $#ARGV+1;
if ( $opt != 0 ) {
	print STDERR "NG:usage send-bucket.pl\n";

	exit 1;
}

# 送信バケットを選択
#
unless (chdir $BucketDir) {
	wrt_log($pname, 'err', "Can not change $BucketDir:$!");
	exit 2;
}
my @bdir_lst = glob("[0-9]*/*-RDY-*.ctl");	# ID/YYYYMMDD-RDY-n.ctlのリストを作成

if ( @bdir_lst ) {	# 送信バケットが存在するか
	# リストをソート
	@bdir_lst = map {$_->[0]}
			sort {$a->[1] <=> $b->[1]}
			map {[$_, /^(\d+)\/\w+/]} @bdir_lst;

	if ($debug) {my $i=0; foreach my $dir (@bdir_lst) { printf "bdir[%d] = %s\n", $i++, $dir; }}

	# IDが一番小さい && コントロールファイルは"RDY"
	#   -> $bdir_lst[0] を選択
	#
	# バケットディレクトリとコントロールファイルを分離
	($snd_bucket, $ctrl_file) = split /\//, $bdir_lst[0];
	# コントロールファイルのリトライカウントを取得
	$ctrl_file =~ /(\d+)-(\w+)-(\d+)\.ctl/;
	$exec_date = $1;
	$send_stat = $2;
	$rtry_cnt = $3;

	if ($debug) {print "snd_bucket = '$snd_bucket' ctrl_file = '$ctrl_file'\n"}
} else {
	# 送信すべきバケットがないので、ログを記録して終了
	wrt_log($pname, 'info', "Sending buckets not exist");
	exit;
}

# FTP送信開始
#
# 送信バケットに移動
unless (chdir "$BucketDir/$snd_bucket") {
	wrt_log($pname, 'err', "Can not change $BucketDir/$snd_bucket:$!");
	exit 2;
}

# 排他制御ファイル(__lock__)をロック
unless (open(LCK, $LockFile)) {
	wrt_log($pname, 'err', "Can not open $LockFile:$!");
	exit 2;
}
unless (flock(LCK, 6)) {
	wrt_log($pname, 'warning', "Someone is locking bucket $snd_bucket:$!");
	close(LCK);
	exit;
}

# FTPサーバへ接続
my $ftp = Net::FTP->new($snd_host);
if ($@) {
	wrt_log($pname, 'err', "Can not access to $snd_host:$!");
	close(LCK);
	exit 2;
}
# FTPログイン
unless ($ftp->login($ftp_user, $ftp_pass)) {
	wrt_log($pname, 'err', "Can not login '$snd_host:$ftp_user':" . $ftp->message);
	close(LCK);
	exit 2;
}
# FTPオプション
$ftp->binary;

## 受信するファイルの存在を確認、存在する場合は取得 (ペンディング)
#my $exec_date = "YYYYMMDD";
#my $recv_dir = "/data/RECV";
#
#$ftp->cwd("$RecvDir/pickup");
#my @file_lst = $ftp->ls('.');
#if ( @file_lst ) {
#	if ( ! -d "$recv_dir/$exec_date" ) {
#		mkdir "$recv_dir/$exec_date" or die "Can not mkdir $recv_dir/$exec_date: $!";
#	}
#	foreach my $file ( @file_lst ) {
#		if ($debug) {print "Get $file\n";}
#		$ftp->get($file, "$recv_dir/$exec_date/$file")
#			or die "FTP command fail: " . $ftp->message;
#	}
#}

# 送信準備: バケットを作成して移動 (存在しなければ作成)
$ftp->cwd("$RecvDir");
my @sdir_lst = $ftp->ls('.');
my $fnd_sdir = 0;
foreach my $sdir ( @sdir_lst ) {
	if ( $sdir eq $snd_bucket ) { $fnd_sdir = 1; last; }
}
if ( ! $fnd_sdir ) {
	# 送信先にバケットは存在しないので作成する
	unless ($ftp->mkdir("$snd_bucket")) {
		wrt_log($pname, 'err', "FTP mkdir fail:" . $ftp->message);
		close(LCK);
		exit 2;
	}
}

$ftp->cwd("$snd_bucket");
if ($debug) {printf "current dir = %s\n", $ftp->pwd();}

# 送信開始
# 
wrt_log($pname, 'info', "START sending bucket:$snd_bucket");
# コマンドファイル.tar.gz
my $rslt_file = $ctrl_file;
if ( ! $ftp->put("$TarFileName.tar.gz") ) { # エラー
	# リトライカウントをインクリメント
	$rtry_cnt++;
	if ( $rtry_cnt > $MaxRetryCnt ) {
		# ステータスを"ERR"
		rename $ctrl_file, "$exec_date-ERR-$rtry_cnt.ctl";
		wrt_log($pname, 'err', 
			"FTP put $TarFileName.tar.gz fail:bkt=$snd_bucket:rtry=$rtry_cnt:" . $ftp->message);
		close(LCK);
		exit 2;
	}
	rename $ctrl_file, "$exec_date-RDY-$rtry_cnt.ctl";
} else { # 送信成功
	# 送信先のコントロールファイルのステータスを"END"にする
	$rslt_file =~ s/RDY/END/;
	if ($debug) {print "ctrl_file = '$ctrl_file' rslt_file = '$rslt_file'\n" ;}
	unless ($ftp->put("$ctrl_file", "$rslt_file")) {
		wrt_log($pname, 'err', "FTP put $rslt_file fail:" . $ftp->message);
		close(LCK);
		exit 2;
	}
	rename $ctrl_file, $rslt_file;
}

$ftp->quit;
wrt_log($pname, 'info', "END sending bucket:$snd_bucket");

# 排他制御ファイル(__lock__)をアンロック
close(LCK);

exit;
