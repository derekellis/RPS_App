$(document).ready(function() {
    var audioElement = document.createElement('audio');
    audioElement.setAttribute('src', 'audio/boulder.mp3');
    //audioElement.load()

    $.get();
    $('.boulder').click(function() {
        audioElement.play();
    });
});