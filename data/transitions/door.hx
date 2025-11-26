var transOut:Bool = false;

function create(event) {
    event.cancel();

    transOut = event.transOut;
}