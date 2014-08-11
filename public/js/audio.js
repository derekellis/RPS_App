$(document).ready(function() {
    var audioElement = document.createElement('audio');
    audioElement.setAttribute('src', 'http://10.10.10.10:4567/audio/boulder.mp3');
    //audioElement.load()

    $.get();
    $('.boulder').hover(function() {
        audioElement.play();
    });
});