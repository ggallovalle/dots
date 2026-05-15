import QtQuick
import QtCore
import Quickshell.Io
import qs.Commons
import qs.Services.UI

Item {
    id: runner

    property string url: ""
    property string commandPath: ""

    property string stdoutText: ""
    property string stderrText: ""
    property var commandArgs: []

    function shortenHome(path) {
        if (!path)
            return "";

        var home = StandardPaths.writableLocation(StandardPaths.HomeLocation);
        if (home && path.indexOf(home) === 0) {
            return "~" + path.slice(home.length);
        }

        return path;
    }

    function lastPathSegment(path) {
        if (!path)
            return "";

        var cleaned = path.replace(/\/+$/g, "");
        if (!cleaned)
            return "";

        var parts = cleaned.split("/");
        return parts.length > 0 ? parts[parts.length - 1] : "";
    }

    function normalizeMessage(message) {
        if (!message)
            return "";

        var cleaned = message.replace(/\s+/g, " ").trim();
        cleaned = cleaned.replace(/^ERROR:\s*/i, "");

        if (cleaned.length > 120) {
            cleaned = cleaned.slice(0, 117) + "...";
        }

        return cleaned;
    }

    function parseResult() {
        if (!stdoutText)
            return null;

        try {
            return JSON.parse(stdoutText);
        } catch (_) {
            var lines = stdoutText.split(/\r?\n/);
            for (var i = lines.length - 1; i >= 0; i--) {
                var line = lines[i].trim();
                if (!line)
                    continue;
                if (line[0] !== "{")
                    continue;

                try {
                    return JSON.parse(line);
                } catch (_) {
                }
            }

            return null;
        }
    }

    function resolveType(result) {
        if (result && result.operations && result.operations.length > 0 && result.operations[0].type) {
            return result.operations[0].type;
        }

        return "media";
    }

    function onDone(exitCode) {
        var result = parseResult();

        if (!result) {
            Logger.e("KBMediaGet", "Failed to parse JSON output. exitCode=" + exitCode);
            Logger.e("KBMediaGet", "stdout=" + stdoutText);
            Logger.e("KBMediaGet", "stderr=" + stderrText);
            ToastService.showError("Media fetch failed: invalid JSON output");
            destroy();
            return;
        }

        var firstOp = (result.operations && result.operations.length > 0) ? result.operations[0] : null;
        var type = resolveType(result);

        if (result.ok) {
            var outputPath = firstOp && firstOp.outputPath ? shortenHome(firstOp.outputPath) : "";
            var downloadedName = firstOp && firstOp.outputPath ? lastPathSegment(firstOp.outputPath) : "";
            if (outputPath) {
                var message = "Saved " + type + " to " + outputPath;
                if (downloadedName)
                    message += "\n" + downloadedName;
                ToastService.showNotice(message);
            } else {
                ToastService.showNotice("Saved " + type);
            }
            destroy();
            return;
        }

        var errorMessage = "";
        if (firstOp && firstOp.stderr)
            errorMessage = firstOp.stderr;
        else if (firstOp && firstOp.error && firstOp.error.message)
            errorMessage = firstOp.error.message;
        else if (result.errors && result.errors.length > 0 && result.errors[0].message)
            errorMessage = result.errors[0].message;
        else if (stderrText)
            errorMessage = stderrText;
        else
            errorMessage = "exit code " + exitCode;

        errorMessage = normalizeMessage(errorMessage);
        if (errorMessage) {
            ToastService.showError(type + " failed: " + errorMessage);
        } else {
            ToastService.showError(type + " failed");
        }

        destroy();
    }

    Process {
        id: process
        command: runner.commandArgs

        stdout: StdioCollector {
            onTextChanged: {
                runner.stdoutText = text;
            }
        }

        stderr: StdioCollector {
            onTextChanged: {
                runner.stderrText = text;
            }
        }

        onExited: function(exitCode) {
            runner.onDone(exitCode);
        }

        Component.onCompleted: {
            runner.commandArgs = [
                "bun",
                "run",
                runner.commandPath,
                "--",
                "media",
                "get",
                "--json",
                runner.url
            ];
            Logger.i("KBMediaGet", "Executing: " + runner.commandArgs.join(" "));
            running = true;
        }
    }
}
