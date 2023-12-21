// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';


function customBlockComment() {
    const editor = vscode.window.activeTextEditor;
    if (!editor) { // No open text editor
        return; 
    }

    
    // We want to ignore leading tabs for the first line to make it easier to parse 
    let selection = editor.selection;
    const firstLine = editor.document.lineAt(selection.start.line);
    const firstNonTabPosition = firstLine.firstNonWhitespaceCharacterIndex;
    const adjustedStart = selection.start.with(undefined, firstNonTabPosition);
    selection = new vscode.Selection(adjustedStart, selection.end);

    const text = editor.document.getText(selection);
    const lines = text.split('\n');
    const isFirstLineCommented = lines[0].startsWith('#\t');

    const processedLines = lines.map((line, index) => {
        if (index === 0) {
            if (isFirstLineCommented) {
                // Uncomment the first line by removing #\t
                return line.substring(2);
            } else {
                // Comment the first line
                return '#\t' + line;
            }
        } else {
            if (isFirstLineCommented) {
                // Remove indentation from subsequent lines
                return line.startsWith('\t') ? line.substring(1) : line;
            } else {
                // Indent subsequent lines
                return '\t' + line;
            }
        }
    });

    const modifiedText = processedLines.join('\n');

    editor.edit(editBuilder => {
        editBuilder.replace(selection, modifiedText);
    });
}


// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "alicorn-test" is now active!');

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with registerCommand
	// The commandId parameter must match the command field in package.json
	let helloWorldSub = vscode.commands.registerCommand('alicorn-test.helloWorld', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		vscode.window.showInformationMessage('Aaaaaaaabbcc from Alicorn Test!');
	});

	/* // I would like to force the user to only ever use tabs but this doesn't seem to work right now.
	// gpt-4 generated, may be nonsense
	// supposed to override user settings and force tabs on tab press
	vscode.workspace.onDidOpenTextDocument(document => {
		if (document.languageId === 'alicorn') {
		  const config = vscode.workspace.getConfiguration('[alicorn]', document.uri);
		  const insertSpaces = config.get('editor.insertSpaces');
		  if (insertSpaces) {
			config.update('editor.insertSpaces', false, vscode.ConfigurationTarget.Workspace);
			config.update('editor.tabSize', 4, vscode.ConfigurationTarget.Workspace);
		  }
		}
	  });*/
	context.subscriptions.push(helloWorldSub);

    let customBlockCommentSub = vscode.commands.registerCommand('alicorn.customBlockComment', () => {
        customBlockComment();
    });

    context.subscriptions.push(customBlockCommentSub);


}

// This method is called when your extension is deactivated
export function deactivate() {}
