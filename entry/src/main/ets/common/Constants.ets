/**
 * 常量定义
 */
export class Constants {
  // 应用信息
  static readonly APP_NAME = 'OpenClaw';
  static readonly APP_VERSION = '1.0.0';
  
  // 颜色
  static readonly COLORS = {
    PRIMARY: '#2196F3',
    SECONDARY: '#4CAF50',
    BACKGROUND: '#16213e',
    CARD_BG: '#0f3460',
    TEXT_PRIMARY: '#FFFFFF',
    TEXT_SECONDARY: '#888888',
    TERMINAL_BG: '#0a0a0a',
    TERMINAL_TEXT: '#00FF00'
  };
  
  // 终端默认配置
  static readonly TERMINAL = {
    DEFAULT_COLS: 80,
    DEFAULT_ROWS: 24,
    FONT_SIZE: 14,
    FONT_FAMILY: 'monospace',
    SCROLLBACK: 1000
  };
  
  // 超时设置
  static readonly TIMEOUT = {
    COMMAND_DEFAULT: 30000,
    DOWNLOAD: 300000,
    INSTALL: 600000
  };
  
  // URL
  static readonly URLS = {
    BOOTSTRAP: 'https://example.com/bootstrap-arm64.tar.gz',
    WWW: 'https://example.com/www.zip',
    CONFIG: 'https://example.com/config.json'
  };
  
  // 文件路径
  static readonly PATHS = {
    PREFIX: 'usr',
    HOME: 'home',
    WWW: 'www',
    CONFIG: '.openclaw-android'
  };
  
  // 事件名称
  static readonly EVENTS = {
    VIEW_CHANGE: 'viewChange',
    SETUP_PROGRESS: 'setup_progress',
    SETUP_COMPLETE: 'setup_complete',
    SETUP_ERROR: 'setup_error',
    COMMAND_OUTPUT: 'command_output',
    SESSION_CHANGE: 'sessionChange'
  };
}

export default Constants;
