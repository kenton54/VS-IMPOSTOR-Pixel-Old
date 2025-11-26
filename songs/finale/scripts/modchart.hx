function onPostStrumCreation(event) {
    if (strumLines.members[0] != event.strum.strumLine) return;
}

function postUIOverhaul() {
    strumLines.members[0].forEach(function(strum) {
        strum.visible = false;
    });
}