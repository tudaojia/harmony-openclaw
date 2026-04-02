/**
 * WebView 与 ArkTS 桥接
 * 提供双向通信能力
 */
import webview from '@ohos.web.webview';
import { TerminalSessionManager } from '../models/TerminalSession';
import { BootstrapManager } from '../models/BootstrapManager';
import { CommandRunner } from '../utils/CommandRunner';
import { EnvironmentBuilder } from '../utils/EnvironmentBuilder';

export class JsBridge {
  private sessionManager: TerminalSessionManager;
  private bootstrapManager: BootstrapManager;
  private context: any;
  private webController: webview.WebviewController;

  constructor(
    context: any,
    sessionManager: TerminalSessionManager,
    bootstrapManager: BootstrapManager,
    webController: webview.WebviewController
  ) {
    this.context = context;
    this.sessionManager = sessionManager;
    this.bootstrapManager = bootstrapManager;
    this.webController = webController;
  }

  /**
   * 注册到 WebView
   */
  register() {
    this.webController.registerJavaScriptProxy(this, 'OpenClaw', [
      'showTerminal',
      'showWebView',
      'createSession',
      'switchSession',
      'closeSession',
      'getTerminalSessions',
      'writeToTerminal',
      'runCommand',
      'getSetupStatus',
      'startSetup',
      'getStorageInfo',
      'getNetworkStatus',
      'getSystemInfo',
      'copyToClipboard'
    ]);
  }

  // ========== 终端域 ==========

  showTerminal() {
    // 发送事件到 UI
    this.emit('viewChange', { view: 'terminal' });
  }

  showWebView() {
    this.emit('viewChange', { view: 'main' });
  }

  createSession(): string {
    const session = this.sessionManager.createSession();
    return JSON.stringify({
      id: session.id,
      name: session.title
    });
  }

  switchSession(id: string) {
    this.sessionManager.switchSession(id);
  }

  closeSession(id: string) {
    this.sessionManager.closeSession(id);
  }

  getTerminalSessions(): string {
    return JSON.stringify(this.sessionManager.getSessionsInfo());
  }

  writeToTerminal(id: string, data: string) {
    const session = id ? this.sessionManager.getSessionById(id) : this.sessionManager.activeSession;
    if (session) {
      session.write(data);
    }
  }

  // ========== 命令域 ==========

  runCommand(cmd: string): string {
    const env = EnvironmentBuilder.build(this.context);
    const result = CommandRunner.runSync(cmd, env, this.bootstrapManager.homeDir);
    return JSON.stringify(result);
  }

  // ========== 设置域 ==========

  getSetupStatus(): string {
    return JSON.stringify(this.bootstrapManager.getStatus());
  }

  startSetup() {
    // 异步执行安装
    this.bootstrapManager.startSetup((progress, message) => {
      this.emit('setup_progress', { progress, message });
    }).then(() => {
      this.emit('setup_complete', { success: true });
    }).catch((e) => {
      this.emit('setup_error', { error: String(e) });
    });
  }

  // ========== 系统域 ==========

  getStorageInfo(): string {
    const filesDir = this.context.filesDir;
    // 简化的存储信息
    return JSON.stringify({
      totalBytes: 64 * 1024 * 1024 * 1024, // 64GB
      freeBytes: 32 * 1024 * 1024 * 1024,  // 32GB
      bootstrapBytes: 200 * 1024 * 1024,   // 200MB
      wwwBytes: 10 * 1024 * 1024           // 10MB
    });
  }

  getNetworkStatus(): string {
    // 简化的网络状态
    return JSON.stringify({
      connected: true,
      type: 'wifi'
    });
  }

  getSystemInfo(): string {
    return JSON.stringify({
      os: 'harmony',
      version: '4.0.0',
      api: 10,
      device: 'HarmonyOS Device',
      model: 'Unknown'
    });
  }

  copyToClipboard(text: string) {
    // TODO: 实现剪贴板
    this.emit('clipboard', { text });
  }

  // ========== 事件系统 ==========

  private emit(event: string, data: any) {
    const js = `window.OpenClawEvents.emit('${event}', ${JSON.stringify(data)})`;
    this.webController.runJavaScript(js);
  }
}

export default JsBridge;
