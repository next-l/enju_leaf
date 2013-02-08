#
# コンフィグレーション
#
$BucketDir   = "/var/enjusync_snd";
$RecvDir     = "/var/enjusync_rcv";
$StatFileDir = "$BucketDir/work";
$TarFileName = "dumpfiles";
$LockFile    = "__lock__";
$MaxRetryCnt = 3;

# syslog関連
#
$ModuleName  = "EnjuSync";
$Facility    = 'local1';
