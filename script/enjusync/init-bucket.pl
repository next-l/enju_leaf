eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
	if 0;
my $pname = $0; $pname =~ s/.*\/(.*)/$1/s; # プログラム名取得
#
# 送信バケット準備処理
#
# init-bucket.pl
#

use strict;
use vars qw/$opt_d/;
use vars qw/$BucketDir $TarFileName $LockFile/;

use POSIX 'strftime';
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
my $bkt_dir = "";			# 送信バケットディレクトリ
my $cur_dir = Cwd::cwd();	# カレントディレクトリ

# 引数のチェック
my $opt = $#ARGV+1;

if ( $debug ) {print "arg cnt = $opt\n";}
if ( $opt == 1 ) {
	$bkt_dir = $ARGV[0];
} elsif ( $opt == 0 || $opt >= 2 ) {
	print STDERR "NG:usage: init-bucket.pl ID\n";

	exit 1;
}
if ( $debug ) {print "arg1 = '$bkt_dir'\n";}

# 
# 送信バケットを準備する
# 
my $exec_date = strftime "%Y%m%d", localtime;	# 実行日の取得

# 送信バケットへ移動
unless (chdir "$BucketDir/$bkt_dir") {
	wrt_log($pname, 'err', "Can not change $BucketDir/$bkt_dir:$!");
	exit 2;
}
# 送信バケットにコマンドファイルをアーカイブ＋圧縮ファイル生成
# 
# コマンドファイルがあるかチェックする 
my @cmdfile_lst = glob("*.marshal");
if ($debug) {foreach my $cmdfile (@cmdfile_lst) { print "$cmdfile\n"; }}

unless ( @cmdfile_lst ) {
	# コマンドファイルが無い場合、ステータスEND、exit3で終了
	my $Ctl_File = "$exec_date-END-0.ctl";
	unless (open(OUT, "> $Ctl_File")) {
		wrt_log($pname, 'err', "Can not open $BucketDir/$bkt_dir/$Ctl_File (no update):$!");
		exit 2;
	}
	wrt_log($pname, 'info', "No update:$BucketDir/$bkt_dir");
	exit 3;
}

# tarにてアーカイブ＋圧縮、送信バケットへ移動してコピー
my $tar = Archive::Tar->new;
$tar->add_files(@cmdfile_lst);
$tar->write("$BucketDir/$bkt_dir/$TarFileName.tar.gz", 6);

# コントロールファイル生成 (ステータスを"RDY"にする)
my $Ctl_File = "$exec_date-RDY-0.ctl";
unless (open(OUT, "> $Ctl_File")) {
	wrt_log($pname, 'err', "Can not open $BucketDir/$bkt_dir/$Ctl_File:$!");
	exit 2;
}

# チェックサム(md5)とファイルサイズをコントロールファイルに書き込む
my $file_sz = -s "$TarFileName.tar.gz";
chomp(my $file_md5sum = `/usr/bin/md5sum $TarFileName.tar.gz`);
$file_md5sum =~ /(\w+)\s*(\w+)/;
my $chk_sum = $1;	# md5sumの値を分離
print OUT "$file_sz\n";
print OUT "$chk_sum\n";

close(OUT);

# 排他制御ファイルの作成
# 
# ロックファイル(__lock__)の生成
unless (open(LCK, "> $LockFile")) {
	wrt_log($pname, 'err', "Can not make $BucketDir/$bkt_dir/$LockFile:$!");
	exit 2;
}
close(LCK);

exit;

