/**
 * Bootstrap 安装管理器
 * 负责初始化开发环境
 */
import fs from '@ohos.file.fs';
import http from '@ohos.net.http';
import common from '@ohos.app.ability.common';

export interface BootstrapStatus {
  installed: boolean;
  version: string;
  prefixPath: string;
  homePath: string;
  progress: number;
  message: string;
}

export class BootstrapManager {
  private context: common.Context;
  private _prefixDir: string;
  private _homeDir: string;
  private _wwwDir: string;
  private _isInstalled: boolean = false;
  private _needsPostSetup: boolean = false;
  private _status: BootstrapStatus = {
    installed: false,
    version: '0.0.0',
    prefixPath: '',
    homePath: '',
    progress: 0,
    message: '未初始化'
  };

  // 下载 URL
  private readonly BOOTSTRAP_URL = 'https://example.com/bootstrap-arm64.tar.gz';
  private readonly WWW_URL = 'https://example.com/www.zip';

  constructor(context: common.Context) {
    this.context = context;
    
    // 设置目录路径
    this._prefixDir = this.context.filesDir + '/usr';
    this._homeDir = this.context.filesDir + '/home';
    this._wwwDir = this.context.filesDir + '/www';
    
    // 检查安装状态
    this.checkInstallation();
  }

  get prefixDir(): string {
    return this._prefixDir;
  }

  get homeDir(): string {
    return this._homeDir;
  }

  get wwwDir(): string {
    return this._wwwDir;
  }

  get postSetupScript(): File {
    return new File(this._homeDir + '/.post-setup.sh');
  }

  /**
   * 检查安装状态
   */
  private checkInstallation() {
    try {
      // 检查关键目录是否存在
      const prefixExists = this.dirExists(this._prefixDir);
      const homeExists = this.dirExists(this._homeDir);
      
      this._isInstalled = prefixExists && homeExists;
      
      // 检查是否需要后续设置
      if (this._isInstalled) {
        const markerFile = this._homeDir + '/.openclaw-android/.setup-complete';
        this._needsPostSetup = !this.fileExists(markerFile);
      }
      
      this._status = {
        installed: this._isInstalled,
        version: this.getInstalledVersion(),
        prefixPath: this._prefixDir,
        homePath: this._homeDir,
        progress: this._isInstalled ? 100 : 0,
        message: this._isInstalled ? '已安装' : '未安装'
      };
    } catch (e) {
      console.error('检查安装状态失败: ' + e);
      this._isInstalled = false;
    }
  }

  /**
   * 获取安装版本
   */
  private getInstalledVersion(): string {
    try {
      const versionFile = this._prefixDir + '/VERSION';
      if (this.fileExists(versionFile)) {
        return this.readFile(versionFile).trim();
      }
    } catch (e) {
      console.error('读取版本失败: ' + e);
    }
    return 'unknown';
  }

  /**
   * 是否已安装
   */
  isInstalled(): boolean {
    return this._isInstalled;
  }

  /**
   * 是否需要后续设置
   */
  needsPostSetup(): boolean {
    return this._needsPostSetup;
  }

  /**
   * 获取状态
   */
  getStatus(): BootstrapStatus {
    return this._status;
  }

  /**
   * 开始安装
   */
  async startSetup(onProgress: (progress: number, message: string) => void): Promise<void> {
    try {
      // 阶段1: 准备目录
      onProgress(0.05, '创建目录...');
      await this.createDirectories();
      
      // 阶段2: 下载 bootstrap
      onProgress(0.1, '下载基础环境...');
      await this.downloadBootstrap(onProgress);
      
      // 阶段3: 解压 bootstrap
      onProgress(0.4, '解压基础环境...');
      await this.extractBootstrap(onProgress);
      
      // 阶段4: 下载 www
      onProgress(0.6, '下载 Web 资源...');
      await this.downloadWww(onProgress);
      
      // 阶段5: 解压 www
      onProgress(0.8, '解压 Web 资源...');
      await this.extractWww(onProgress);
      
      // 阶段6: 配置环境
      onProgress(0.9, '配置环境...');
      await this.configureEnvironment();
      
      // 阶段7: 完成
      onProgress(1.0, '安装完成!');
      this._isInstalled = true;
      this._needsPostSetup = true;
      
    } catch (e) {
      onProgress(0, '安装失败: ' + e);
      throw e;
    }
  }

  /**
   * 创建目录
   */
  private async createDirectories(): Promise<void> {
    const dirs = [
      this._prefixDir,
      this._prefixDir + '/bin',
      this._prefixDir + '/lib',
      this._prefixDir + '/etc',
      this._homeDir,
      this._homeDir + '/.openclaw-android',
      this._wwwDir
    ];
    
    for (const dir of dirs) {
      if (!this.dirExists(dir)) {
        fs.mkdirSync(dir);
      }
    }
  }

  /**
   * 下载 bootstrap
   */
  private async downloadBootstrap(
    onProgress: (progress: number, message: string) => void
  ): Promise<void> {
    const httpRequest = http.createHttp();
    
    try {
      const response = await httpRequest.request(this.BOOTSTRAP_URL, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER
      });
      
      if (response.responseCode === 200) {
        const destPath = this.context.cacheDir + '/bootstrap.tar.gz';
        // 保存文件
        const file = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
        fs.writeSync(file.fd, response.result as ArrayBuffer);
        fs.closeSync(file);
        onProgress(0.35, '下载完成');
      } else {
        throw new Error('下载失败: ' + response.responseCode);
      }
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 解压 bootstrap
   */
  private async extractBootstrap(
    onProgress: (progress: number, message: string) => void
  ): Promise<void> {
    // HarmonyOS 需要使用原生解压库
    // 这里是简化实现
    onProgress(0.5, '解压中...');
    // TODO: 实现解压逻辑
  }

  /**
   * 下载 www
   */
  private async downloadWww(
    onProgress: (progress: number, message: string) => void
  ): Promise<void> {
    const httpRequest = http.createHttp();
    
    try {
      const response = await httpRequest.request(this.WWW_URL, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER
      });
      
      if (response.responseCode === 200) {
        const destPath = this.context.cacheDir + '/www.zip';
        const file = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
        fs.writeSync(file.fd, response.result as ArrayBuffer);
        fs.closeSync(file);
        onProgress(0.7, '下载完成');
      }
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 解压 www
   */
  private async extractWww(
    onProgress: (progress: number, message: string) => void
  ): Promise<void> {
    onProgress(0.85, '解压中...');
    // TODO: 实现解压逻辑
  }

  /**
   * 配置环境
   */
  private async configureEnvironment(): Promise<void> {
    // 创建配置文件
    const config = {
      version: '1.0.0',
      prefix: this._prefixDir,
      home: this._homeDir,
      www: this._wwwDir
    };
    
    const configPath = this._homeDir + '/.openclaw-android/config.json';
    this.writeFile(configPath, JSON.stringify(config, null, 2));
    
    // 创建环境变量脚本
    const envScript = `#!/bin/sh
export HOME="${this._homeDir}"
export PREFIX="${this._prefixDir}"
export PATH="${this._prefixDir}/bin:$PATH"
export LD_LIBRARY_PATH="${this._prefixDir}/lib:$LD_LIBRARY_PATH"
`;
    
    const envPath = this._homeDir + '/.openclaw-android/env.sh';
    this.writeFile(envPath, envScript);
  }

  // 辅助方法
  private dirExists(path: string): boolean {
    try {
      const stat = fs.statSync(path);
      return stat.isDirectory();
    } catch (e) {
      return false;
    }
  }

  private fileExists(path: string): boolean {
    try {
      const stat = fs.statSync(path);
      return stat.isFile();
    } catch (e) {
      return false;
    }
  }

  private readFile(path: string): string {
    const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
    const content = fs.readSync(file.fd, 1024);
    fs.closeSync(file);
    return String.fromCharCode.apply(null, new Uint8Array(content));
  }

  private writeFile(path: string, content: string): void {
    const file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
    fs.writeSync(file.fd, content);
    fs.closeSync(file);
  }
}

export default BootstrapManager;
