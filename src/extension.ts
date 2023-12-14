// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "alicorn-test" is now active!');

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with registerCommand
	// The commandId parameter must match the command field in package.json
	let disposable = vscode.commands.registerCommand('alicorn-test.helloWorld', () => {
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
	context.subscriptions.push(disposable);
}

// This method is called when your extension is deactivated
export function deactivate() {}
