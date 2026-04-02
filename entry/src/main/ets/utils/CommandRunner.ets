/**
 * 命令执行器
 * 贌责执行 shell 命令并返回结果
 */
import childProcess from '@ohos.childProcess';

export interface CommandResult {
  stdout: string;
  stderr: string;
  exitCode: number;
  success: boolean;
}

export interface CommandOptions {
  cwd?: string;
  env?: Map<string, string>;
  timeout?: number;
}

export class CommandRunner {
  private static DEFAULT_TIMEOUT = 30000; // 30秒

  /**
   * 同步执行命令
   */
  static runSync(
    command: string,
    env?: Map<string, string>,
    cwd?: string,
    timeoutMs?: number
  ): CommandResult {
    const timeout = timeoutMs || CommandRunner.DEFAULT_TIMEOUT;
    
    try {
      // 构建环境变量
      const envArray: string[] = [];
      if (env) {
        env.forEach((value, key) => {
          envArray.push(`${key}=${value}`);
        });
      }
      
      // 执行命令
      const result = childProcess.execSync(command, {
        cwd: cwd,
        env: envArray,
        timeout: timeout
      });
      
      return {
        stdout: result.stdout || '',
        stderr: result.stderr || '',
        exitCode: result.exitCode || 0,
        success: result.exitCode === 0
      };
    } catch (e) {
      return {
        stdout: '',
        stderr: String(e),
        exitCode: -1,
        success: false
      };
    }
  }

  /**
   * 异步执行命令（流式输出）
   */
  static async runStreaming(
    command: string,
    env?: Map<string, string>,
    cwd?: string,
    onOutput?: (output: string) => void
  ): Promise<CommandResult> {
    return new Promise((resolve, reject) => {
      let stdout = '';
      let stderr = '';
      
      try {
        const envArray: string[] = [];
        if (env) {
          env.forEach((value, key) => {
            envArray.push(`${key}=${value}`);
          });
        }
        
        const child = childProcess.spawn(command, [], {
          cwd: cwd,
          env: envArray
        });
        
        // 监听标准输出
        child.stdout.on('data', (data: string) => {
          stdout += data;
          if (onOutput) {
            onOutput(data);
          }
        });
        
        // 监听错误输出
        child.stderr.on('data', (data: string) => {
          stderr += data;
          if (onOutput) {
            onOutput(data);
          }
        });
        
        // 监听退出
        child.on('close', (code: number) => {
          resolve({
            stdout,
            stderr,
            exitCode: code,
            success: code === 0
          });
        });
        
        // 监听错误
        child.on('error', (err: Error) => {
          resolve({
            stdout,
            stderr: String(err),
            exitCode: -1,
            success: false
          });
        });
        
      } catch (e) {
        resolve({
          stdout: '',
          stderr: String(e),
          exitCode: -1,
          success: false
        });
      }
    });
  }

  /**
   * 执行命令并返回 Promise
   */
  static async run(
    command: string,
    options?: CommandOptions
  ): Promise<CommandResult> {
    const env = options?.env;
    const cwd = options?.cwd;
    const timeout = options?.timeout || CommandRunner.DEFAULT_TIMEOUT;
    
    return this.runSync(command, env, cwd, timeout);
  }

  /**
   * 检查命令是否存在
   */
  static commandExists(command: string): boolean {
    const result = this.runSync(`command -v ${command}`);
    return result.success && result.stdout.trim().length > 0;
  }

  /**
   * 获取命令路径
   */
  static which(command: string): string | null {
    const result = this.runSync(`command -v ${command}`);
    if (result.success) {
      return result.stdout.trim();
    }
    return null;
  }
}

export default CommandRunner;
