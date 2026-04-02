/**
 * 终端会话管理器
 * 管理多个终端会话的生命周期
 */
export class TerminalSessionManager {
  private sessions: Map<string, TerminalSession> = new Map()
  private activeSessionId: string = ''
  private onSessionsChanged: (() => void) | null = null

  constructor() {
    // 初始化
  }

  /**
   * 创建新会话
   */
  createSession(): TerminalSession {
    const id = this.generateId()
    const session = new TerminalSession(id)
    this.sessions.set(id, session)
    this.activeSessionId = id
    this.notifyChange()
    return session
  }

  /**
   * 获取活动会话
   */
  get activeSession(): TerminalSession | null {
    if (!this.activeSessionId) return null
    return this.sessions.get(this.activeSessionId) || null
  }

  /**
   * 切换会话
   */
  switchSession(id: string): boolean {
    if (!this.sessions.has(id)) return false
    this.activeSessionId = id
    this.notifyChange()
    return true
  }

  /**
   * 关闭会话
   */
  closeSession(id: string): boolean {
    const session = this.sessions.get(id)
    if (!session) return false
    
    session.destroy()
    this.sessions.delete(id)
    
    // 如果关闭的是活动会话，切换到其他会话
    if (this.activeSessionId === id) {
      const remaining = Array.from(this.sessions.keys())
      this.activeSessionId = remaining[0] || ''
    }
    
    this.notifyChange()
    return true
  }

  /**
   * 获取所有会话信息
   */
  getSessionsInfo(): Array<Record<string, any>> {
    const result: Array<Record<string, any>> = []
    this.sessions.forEach((session, id) => {
      result.push({
        id: id,
        name: session.title,
        active: id === this.activeSessionId,
        finished: session.finished
      })
    })
    return result
  }

  /**
   * 设置会话变更回调
   */
  setOnSessionsChanged(callback: () => void) {
    this.onSessionsChanged = callback
  }

  /**
   * 获取会话数量
   */
  get sessionCount(): number {
    return this.sessions.size
  }

  /**
   * 根据ID获取会话
   */
  getSessionById(id: string): TerminalSession | null {
    return this.sessions.get(id) || null
  }

  private generateId(): string {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  private notifyChange() {
    if (this.onSessionsChanged) {
      this.onSessionsChanged()
    }
  }
}

/**
 * 终端会话类
 */
export class TerminalSession {
  private _id: string
  private _title: string
  private _finished: boolean = false
  private _buffer: string[] = []
  private _cursorX: number = 0
  private _cursorY: number = 0
  private _cols: number = 80
  private _rows: number = 24
  private _env: Map<string, string> = new Map()
  private _cwd: string = '/data/local/tmp'
  private _onData: ((data: string) => void) | null = null
  private _onTitleChange: ((title: string) => void) | null = null

  constructor(id: string) {
    this._id = id
    this._title = 'Terminal'
    this.initEnvironment()
  }

  get id(): string {
    return this._id
  }

  get title(): string {
    return this._title
  }

  get finished(): boolean {
    return this._finished
  }

  get cols(): number {
    return this._cols
  }

  get rows(): number {
    return this._rows
  }

  get cwd(): string {
    return this._cwd
  }

  /**
   * 初始化环境变量
   */
  private initEnvironment() {
    this._env.set('HOME', '/data/local/tmp')
    this._env.set('PATH', '/usr/local/bin:/usr/bin:/bin')
    this._env.set('TERM', 'xterm-256color')
    this._env.set('SHELL', '/bin/sh')
    this._env.set('LANG', 'en_US.UTF-8')
  }

  /**
   * 写入数据到终端
   */
  write(data: string) {
    // 处理输入数据
    this.processInput(data)
  }

  /**
   * 处理输入
   */
  private processInput(data: string) {
    // 简化的输入处理
    for (const char of data) {
      this.processChar(char)
    }
  }

  /**
   * 处理单个字符
   */
  private processChar(char: string) {
    // 处理特殊字符
    switch (char) {
      case '\n':
        this._cursorY++
        this._cursorX = 0
        break
      case '\r':
        this._cursorX = 0
        break
      case '\t':
        this._cursorX = (this._cursorX + 8) & ~7
        break
      case '\b':
        if (this._cursorX > 0) {
          this._cursorX--
        }
        break
      default:
        // 普通字符
        this.putChar(char)
        break
    }
    
    // 滚动处理
    if (this._cursorY >= this._rows) {
      this.scrollUp()
      this._cursorY = this._rows - 1
    }
  }

  /**
   * 放置字符
   */
  private putChar(char: string) {
    const index = this._cursorY * this._cols + this._cursorX
    this._buffer[index] = char
    this._cursorX++
    if (this._cursorX >= this._cols) {
      this._cursorX = 0
      this._cursorY++
    }
  }

  /**
   * 向上滚动
   */
  private scrollUp() {
    // 移除第一行
    this._buffer.splice(0, this._cols)
    // 添加空行
    for (let i = 0; i < this._cols; i++) {
      this._buffer.push(' ')
    }
  }

  /**
   * 获取终端内容
   */
  getContent(): string {
    let result = ''
    for (let y = 0; y < this._rows; y++) {
      for (let x = 0; x < this._cols; x++) {
        const index = y * this._cols + x
        result += this._buffer[index] || ' '
      }
      result += '\n'
    }
    return result
  }

  /**
   * 获取光标位置
   */
  getCursor(): { x: number, y: number } {
    return { x: this._cursorX, y: this._cursorY }
  }

  /**
   * 设置终端大小
   */
  resize(cols: number, rows: number) {
    this._cols = cols
    this._rows = rows
    // 重新分配缓冲区
    this._buffer = new Array(cols * rows).fill(' ')
  }

  /**
   * 设置标题
   */
  setTitle(title: string) {
    this._title = title
    if (this._onTitleChange) {
      this._onTitleChange(title)
    }
  }

  /**
   * 设置工作目录
   */
  setCwd(cwd: string) {
    this._cwd = cwd
    this._env.set('PWD', cwd)
  }

  /**
   * 获取环境变量
   */
  getEnv(key: string): string | undefined {
    return this._env.get(key)
  }

  /**
   * 设置环境变量
   */
  setEnv(key: string, value: string) {
    this._env.set(key, value)
  }

  /**
   * 设置数据回调
   */
  onData(callback: (data: string) => void) {
    this._onData = callback
  }

  /**
   * 设置标题变更回调
   */
  onTitleChange(callback: (title: string) => void) {
    this._onTitleChange = callback
  }

  /**
   * 销毁会话
   */
  destroy() {
    this._finished = true
    this._buffer = []
    this._onData = null
    this._onTitleChange = null
  }
}

export default TerminalSessionManager
