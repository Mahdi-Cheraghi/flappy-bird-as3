(function () {

    // Get the path of the current script and construct the path to Main.fla
    var root = fl.scriptURI.substring(0, fl.scriptURI.lastIndexOf("/"));
    var mainFla = root + "/Main.fla";

    if (!FLfile.exists(mainFla)) {
        fl.trace("Main.fla not found");
        return;
    }

    var doc = fl.openDocument(mainFla);

    if (!doc) {
        fl.trace("Could not open Main.fla");
        return;
    }

    doc.save();
    doc.testMovie();

})();