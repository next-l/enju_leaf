#
# コンフィグレーション
#
$ProgHome    = "/opt/enju_trunk";
$BucketDir   = "/var/enjusync";
$RecvDir     = "/var/enjusync";
$StatFileDir = "$BucketDir/work";
$TarFileName = "dumpfiles";
$LockFile    = "__lock__";
$MaxRetryCnt = 3;

# syslog関連
#
$ModuleName  = "EnjuSync";
$Facility    = 'local1';
