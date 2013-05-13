function playSound(audiofilename) {
  var appVersion = window.navigator.appVersion.toLowerCase();
  if (appVersion.indexOf("msie 8.") != -1) {
    return
  } else {
    audio = new Audio("");
    audio.autoplay = true;
    audio.src = audiofilename;
  }
  //audio.play();
}
