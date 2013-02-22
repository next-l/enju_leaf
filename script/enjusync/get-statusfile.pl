eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
	if 0;
my $pname = $0; $pname =~ s/.*\/(.*)/$1/s; # プログラム名取得
#
# ステータスファイル受信処理
#
# get-statusfile.pl
#

use strict;
use vars qw/$opt_d/;
use vars qw/$BucketDir $RecvDir $StatFileDir $LockFile/;

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
my $get_bucket = "";
my $ctrl_file = "";
my $snd_host = "webopac";
my $ftp_user = "ftpenju";
my $ftp_pass = "gota2k12nda";
my $send_stat = "";

# 引数のチェック
my $opt = $#ARGV+1;
if ( $opt != 0 ) {
	print STDERR "NG:usage get-statusfile.pl\n";

	exit 1;
}

# 受信ディレクトリへ移動
#
unless (chdir $StatFileDir) {
	wrt_log($pname, 'err', "Can not change $StatFileDir:$!");
	exit 2;
}

# FTP受信開始
#

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
$ftp->pasv();
$ftp->binary;

# バケットのあるディレクトリへ移動
$ftp->cwd("$RecvDir");
if ($debug) {printf "current dir = %s\n", $ftp->pwd();}

# 受信開始
# 
wrt_log($pname, 'info', "START receive status.marshal");

# 該当する status.marshal を検索

my @file_lst = $ftp->ls('*');
my @imp_lst = grep(/^\d*\/\d+.*-IMP-\d+\.ctl/, @file_lst);

if ($debug) {foreach my $imp ( @imp_lst ) { print "$imp\n"; }}

if ( @imp_lst ) {
	# リストをソート (降順)
	@imp_lst = map {$_->[0]}
		sort {$b->[1] <=> $a->[1]}
		map {[$_, /^(\d+)\/\w+/]} @imp_lst;

	if ($debug) {my $i=0; foreach my $imp ( @imp_lst ) { printf "imp[%d] = %s\n", $i++, $imp; }}
}
# IDが一番大きい && コントロールファイルは"IMP"
#   -> $imp_lst[0] を選択
#
# バケットディレクトリとコントロールファイルを分離
$imp_lst[0] =~ /(\d*)\/.*\.ctl/;
$get_bucket = $1;
if ($debug) {print "get_bucket = $get_bucket\n";}

# 該当するバケットへ移動
$ftp->cwd("$get_bucket");
if ($debug) {printf "current dir = %s\n", $ftp->pwd();}

# status.marshal を取得
unless ( $ftp->get("status.marshal") ) {
	wrt_log($pname, 'err', "Can not receive status.marshal:" . $ftp->message);
	$ftp->quit;
	exit 2;
}

$ftp->quit;

wrt_log($pname, 'info', "END receive status.marshal");

exit;
