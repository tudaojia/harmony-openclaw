/**
 * 环境变量构建器
 * 构建终端会话所需的环境变量
 */
export class EnvironmentBuilder {
  /**
   * 构建环境变量
   */
  static build(context: any): Map<string, string> {
    const env = new Map<string, string>();
    
    // 基础环境变量
    env.set('HOME', context.filesDir + '/home');
    env.set('USER', 'openclaw');
    env.set('SHELL', '/bin/sh');
    env.set('TERM', 'xterm-256color');
    env.set('LANG', 'en_US.UTF-8');
    env.set('LC_ALL', 'en_US.UTF-8');
    
    // 路径
    const prefix = context.filesDir + '/usr';
    env.set('PREFIX', prefix);
    env.set('PATH', `${prefix}/bin:${prefix}/local/bin:/usr/bin:/bin`);
    env.set('LD_LIBRARY_PATH', `${prefix}/lib:${prefix}/local/lib`);
    
    // OpenClaw 特定变量
    env.set('OPENCLAW_HOME', context.filesDir);
    env.set('OPENCLAW_PREFIX', prefix);
    env.set('OPENCLAW_VERSION', '1.0.0');
    
    // TMP 目录
    env.set('TMPDIR', context.cacheDir);
    env.set('TMP', context.cacheDir);
    env.set('TEMP', context.cacheDir);
    
    return env;
  }

  /**
   * 获取 PATH
   */
  static getPath(context: any): string {
    const prefix = context.filesDir + '/usr';
    return `${prefix}/bin:${prefix}/local/bin:/usr/bin:/bin`;
  }

  /**
   * 获取 HOME
   */
  static getHome(context: any): string {
    return context.filesDir + '/home';
  }

  /**
   * 获取 PREFIX
   */
  static getPrefix(context: any): string {
    return context.filesDir + '/usr';
  }

  /**
   * 合并环境变量
   */
  static merge(base: Map<string, string>, override: Map<string, string>): Map<string, string> {
    const result = new Map<string, string>(base);
    override.forEach((value, key) => {
      result.set(key, value);
    });
    return result;
  }

  /**
   * 转换为数组格式
   */
  static toArray(env: Map<string, string>): string[] {
    const result: string[] = [];
    env.forEach((value, key) => {
      result.push(`${key}=${value}`);
    });
    return result;
  }

  /**
   * 从数组解析
   */
  static fromArray(envArray: string[]): Map<string, string> {
    const env = new Map<string, string>();
    for (const item of envArray) {
      const index = item.indexOf('=');
      if (index > 0) {
        const key = item.substring(0, index);
        const value = item.substring(index + 1);
        env.set(key, value);
      }
    }
    return env;
  }
}

export default EnvironmentBuilder;
