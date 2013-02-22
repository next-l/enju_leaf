eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
	if 0;
my $pname = $0; $pname =~ s/.*\/(.*)/$1/s; # プログラム名取得
#
# バケット受信処理
#
# recv-bucket.pl
#

use strict;
use vars qw/$opt_d/;
use vars qw/$ProgHome $RecvDir $TarFileName $LockFile/;

use Getopt::Std;
use Archive::Tar;
use Cwd;

my $debug = 0;
getopts('d');
if ( $opt_d ) { $debug = 1; }

# コンフィグレーションの設定
require "./conf.pl";

# syslogモジュール
require "./logpkg.pl";

# グローバル変数
my $cur_dir = Cwd::cwd();   # カレントディレクトリ
my $rcv_bucket = "";
my $ctrl_file = "";
my $lockfile = "__lock__";
my $exec_date = "";
my $send_stat = "";
my $rtry_cnt = 0;

# 引数のチェック
my $opt = $#ARGV+1;
if ( $opt != 0 ) {
	print STDERR "NG:usage recv-bucket.pl\n";

	exit 1;
}

# 受信バケットを選択
# IDが一番小さい && コントロールファイル名が"END"
#
unless (chdir $RecvDir) {
	wrt_log($pname, 'err', "Can not change $RecvDir: $!");
	exit 2;
}
my @rdir_lst = glob("[0-9]*/*-END-*.ctl");  # ID/YYYYMMDD-END-n.ctlのリストを作成

if ( @rdir_lst ) { # 受信バケットが存在するか
	# リストをソート
    @rdir_lst = map {$_->[0]}
			sort {$a->[1] <=> $b->[1]}
			map {[$_, /^(\d+)\/\w+/]} @rdir_lst;

	if ($debug) {my $i=0; foreach my $dir (@rdir_lst) { printf "rdir[%d] = %s\n", $i++, $dir; }}

    # IDが一番小さい && コントロールファイルは"RDY"
	#   -> $bdir_lst[0] を選択
	#
	# バケットディレクトリとコントロールファイルを分離
	($rcv_bucket, $ctrl_file) = split /\//, $rdir_lst[0];

	if ($debug) {print "rcv_bucket = '$rcv_bucket' ctrl_file = '$ctrl_file'\n"}
} else {
	# 処理すべきバケットがないので、ログを記録して終了
	wrt_log($pname, 'info', "New buckets not exist");
	exit;
}

# 受信バケット処理
#
# 受信バケットに移動
unless (chdir "$RecvDir/$rcv_bucket") {
	wrt_log($pname, 'err', "Can not change $RecvDir/$rcv_bucket 1:$!");
	exit 2;
}

if ( ! -f $lockfile ) {
	# ロックファイル(__lock__)の生成
	unless (open(OUT, "> $LockFile")) {
		wrt_log($pname, 'err', "Can not make $RecvDir/$rcv_bucket/$LockFile:$!");
		exit 2;
	}
	close(OUT);
}

# 排他制御ファイル(__lock__)をロック
unless (open(LCK, $LockFile)) {
	wrt_log($pname, 'err', "Can not open $LockFile:$!");
	exit 2;
}
unless (flock(LCK, 6)) {
	wrt_log($pname, 'warning', "Someone is locking bucket $rcv_bucket:$!");
	close(LCK);
	exit;
}

# コマンドファイル.tar.gzのチェックサムとファイルサイズをチェック
#
unless (open(CTL, "< $ctrl_file")) {
	wrt_log($pname, 'err', "Can not open $RecvDir/$rcv_bucket/$ctrl_file:$!");
	close(LCK);
	exit 2;
}

my $ctrl_sz = <CTL>;
chomp $ctrl_sz;
my $ctrl_md5sum = <CTL>;
chomp $ctrl_md5sum;

close(CTL);

if ($debug) {print "ctrl_sz = $ctrl_sz ctrl_md5sum = '$ctrl_md5sum'\n";}

my $file_sz = -s "$TarFileName.tar.gz";
chomp(my $file_md5sum = `/usr/bin/md5sum $TarFileName.tar.gz`);
$file_md5sum =~ /(\w+)\s*(\w+)/;
my $chk_sum = $1;   # md5sumの値を分離

if ( $ctrl_sz != $file_sz || $ctrl_md5sum ne $chk_sum ) {
	# ファイルサイズとチェックサムが一致していない
	wrt_log($pname, 'err', "Does not match file size or checksum: sz=$file_sz chksum=$chk_sum");
	close(LCK);
	exit 2;
}

# コマンドファイル.tar.gzを展開
if ( -f "$TarFileName.tar.gz" ) {
	my $tar = Archive::Tar->new;
	$tar->read("$TarFileName.tar.gz");
	$tar->extract;
} else {
	wrt_log($pname, 'err', "Not found $TarFileName.tar.gz");
	close(LCK);
	exit 2;
}

# WebOPAC上のデータベースに反映する更新プログラムを実行
#
# プログラムホーム (enju_trunk) に移動
unless (chdir "$ProgHome") {
	wrt_log($pname, 'err', "Can not change $ProgHome:$!");
	exit 2;
}

# 更新プログラム起動
# enju_trunkで実行しないといけない
if ($debug) {print "rake enju:sync:import DUMP_FILE=$RecvDir/$rcv_bucket/enjudump.marshal STATUS_FILE=$RecvDir/$rcv_bucket/status.marshal\n";}
#
# unless (system("rake enju:sync:import DUMP_FILE=$RecvDir/$rcv_bucket/enjudump.marshal STATUS_FILE=$RecvDir/$rcv_bucket/status.marshal")) {
# 	wrt_log($pname, 'err', "Failed import dumpfile: see also /opt/enju_trunk/log/production.log");
# 	close(LCK);
# 	exit 2;
# }
my $r_stat = system("rake enju:sync:import DUMP_FILE=$RecvDir/$rcv_bucket/enjudump.marshal STATUS_FILE=$RecvDir/$rcv_bucket/status.marshal");
if ( $r_stat != 0 ) {
 	wrt_log($pname, 'err', "Failed import dumpfile:status=$r_stat:see also /opt/enju_trunk/log/production.log");
}

# 受信バケットに再移動
unless (chdir "$RecvDir/$rcv_bucket") {
	wrt_log($pname, 'err', "Can not change $RecvDir/$rcv_bucket 2:$!");
	exit 2;
}

#コントロールファイルのステータスを "IMP" にする
my $rslt_file = $ctrl_file;
$rslt_file =~ s/END/IMP/;
rename $ctrl_file, $rslt_file;
if ($debug) {print "rename $ctrl_file, $rslt_file\n";}

# 排他制御ファイル(__lock__)をアンロック
close(LCK);

exit;
