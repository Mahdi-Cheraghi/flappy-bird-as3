(function () {

    // Get the path of the current script and construct the paths to the /fla and /swf directories
    var root = fl.scriptURI.substring(0, fl.scriptURI.lastIndexOf("/"));

    // Assumes all module FLAs live in /fla and publish SWFs
    // into the same directory.
    var flaDir = root + "/fla";

    // Centralized build output used by Main.fla.
    var swfDir = root + "/swf";

    var mainFla = root + "/Main.fla";

    if (!FLfile.exists(flaDir)) {
        fl.trace("No /fla folder found");
        return;
    }

    if (!FLfile.exists(swfDir)) {
        FLfile.createFolder(swfDir);
    }

    // Get all FLA files in the /fla directory
    var files = FLfile.listFolder(flaDir, "files");

    function processFla(file) {

        var flaPath = flaDir + "/" + file;
        fl.trace("Processing: " + file);

        var doc = fl.openDocument(flaPath);

        if (!doc) {
            fl.trace("Cannot open " + file);
            return;
        }

        try {

            doc.save();
            doc.publish();

            var swfName = file.replace(/\.fla$/i, ".swf");

            var src = flaDir + "/" + swfName;
            var dst = swfDir + "/" + swfName;

            if (FLfile.exists(src)) {

                if (FLfile.exists(dst)) {
                    FLfile.remove(dst);
                }

                FLfile.copy(src, dst);

            } else {

                fl.trace("SWF not found: " + src);
            }

            doc.save();

        } catch (e) {

            fl.trace("Error: " + file + " => " + e);
            
        } finally {

            doc.close(true);
        }
    }

    if (files && files.length) {

        for (var i = 0; i < files.length; i++) {

            // Only process FLA files
            if (/\.fla$/i.test(files[i])) {
                processFla(files[i]);
            }
        }
    }

    if (FLfile.exists(mainFla)) {

        var mainDoc = fl.openDocument(mainFla);

        try {

            mainDoc.save();
            mainDoc.publish();
            mainDoc.save();

            mainDoc.testMovie();

        } catch (e2) {
            fl.trace("Main error: " + e2);
        }
    }

    fl.trace("Build completed.");
})();