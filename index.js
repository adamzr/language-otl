'use babel';

import {existsSync, readFileSync} from 'fs';
import {join, relative, dirname, extname} from 'path';
import {exec} from 'child_process';
import {CompositeDisposable} from 'atom';
// import minimatch from 'minimatch';
// import mkdirp from 'mkdirp';

const CONFIGS_FILENAME = 'verify.py';
const EXEC_TIMEOUT = 60 * 1000; // 1 minute

export default {
  activate() {
    this.subscriptions = new CompositeDisposable();
    this.subscriptions.add(
      atom.workspace.observeTextEditors(textEditor => {
        this.subscriptions.add(textEditor.onDidSave(this.handleDidSave.bind(this)));
      })
    );
  },

  deactivate() {
    this.subscriptions.dispose();
  },

  handleDidSave(event) {
    let savedFile = event.path;
    const savedFileDir = dirname(savedFile);
    const rootDir = this.findRootDir(savedFileDir);
    if (!rootDir) {
      return;
    }
    const options = {cwd: rootDir, timeout: EXEC_TIMEOUT};
    let command = "make test"//join(rootDir, 'scripts', CONFIGS_FILENAME);
    atom.notifications.addInfo("Running tests....", {dismissable: true});
    exec(command, options, (err, stdout, stderr) => {
      if (err) {
        atom.notifications.addError(stdout.trim(), {detail: stderr, dismissable: true});
      } else if (stdout) {
        console.log(stdout.trim());
        if(stdout.trim().indexOf("ERROR") === -1){
          atom.notifications.addSuccess(stdout.trim(), {detail: stderr, dismissable: true});
        } else {
          atom.notifications.addError(stdout.trim(), {detail: stderr, dismissable: true});
        }

      }
    });
  },

  findRootDir(dir) {
    if (existsSync(join(dir, 'scripts', CONFIGS_FILENAME))) {
      return dir;
    }
    const parentDir = join(dir, '..');
    if (parentDir === dir) {
      return undefined;
    }
    return this.findRootDir(parentDir);
  },

  // loadConfigs(rootDir) {
  //   const configsFile = join(rootDir, 'scripts', CONFIGS_FILENAME);
  //   let configs = readFileSync(configsFile, 'utf8');
  //   configs = JSON.parse(configs);
  //   if (!Array.isArray(configs)) {
  //     configs = [configs];
  //   }
  //   configs = configs.map(config => this.normalizeConfig(config));
  //   return configs;
  // },
  //
  // normalizeConfig({srcDir, destDir, files, command}) {
  //   if (!srcDir) {
  //     srcDir = '';
  //   }
  //   if (!destDir) {
  //     destDir = srcDir;
  //   }
  //   if (!files) {
  //     throw new Error("on-save: 'files' property is missing in '.on-save.json' configuration file");
  //   }
  //   if (!Array.isArray(files)) {
  //     files = [files];
  //   }
  //   if (!command) {
  //     throw new Error(
  //       "on-save: 'command' property is missing in '.on-save.json' configuration file"
  //     );
  //   }
  //   return {srcDir, destDir, files, command};
  // },
  //
  // run({rootDir, savedFile, config}) {
  //   const matched = config.files.find(glob => {
  //     glob = join(config.srcDir, glob);
  //     return minimatch(savedFile, glob);
  //   });
  //   if (!matched) {
  //     return;
  //   }
  //
  //   const srcFile = savedFile;
  //
  //   let destFile = relative(config.srcDir, savedFile);
  //   destFile = join(config.destDir, destFile);
  //
  //   const extension = extname(destFile);
  //   const destFileWithoutExtension = destFile.substr(0, destFile.length - extension.length);
  //
  //   mkdirp.sync(join(rootDir, dirname(destFile)));
  //
  //   const command = this.resolveCommand(config.command, {
  //     srcFile,
  //     destFile,
  //     destFileWithoutExtension
  //   });
  //   const options = {cwd: rootDir, timeout: EXEC_TIMEOUT};
  //   exec(command, options, (err, stdout, stderr) => {
  //     if (err) {
  //       const message = `on-save: An error occurred while running the command: ${command}`;
  //       atom.notifications.addError(message, {detail: stderr, dismissable: true});
  //     } else if (stdout) {
  //       console.log(stdout.trim());
  //     }
  //   });
  // },
  //
  // resolveCommand(command, vars) {
  //   for (const key of Object.keys(vars)) {
  //     const value = vars[key];
  //     const regExp = new RegExp(`\\$\\{${key}\\}`, 'g');
  //     command = command.replace(regExp, value);
  //   }
  //   return command;
  // }
};
