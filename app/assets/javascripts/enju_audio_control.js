function playSound(audiofilename) {
  if (Calendar.is_ie_compatible || Calendar.is_ie8) {
    return;
  } else {
    audio = new Audio("");
    audio.autoplay = true;
    audio.src = audiofilename;
  }
}
