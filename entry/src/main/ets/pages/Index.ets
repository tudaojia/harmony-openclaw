@Entry
@Component
struct Index {
  @State message: string = 'OpenClaw'
  @State isInstalled: boolean = false
  @State currentView: string = 'main' // main, terminal, setup

  aboutToAppear() {
    // 检查安装状态
    this.checkInstallation()
  }

  checkInstallation() {
    // TODO: 检查 bootstrap 安装状态
    this.isInstalled = false
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('OpenClaw')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        
        Blank()
        
        // 设置按钮
        Button() {
          Text('设置')
            .fontColor(Color.White)
        }
        .backgroundColor('#3366CC')
        .borderRadius(8)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .onClick(() => {
          this.currentView = 'setup'
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#1a1a2e')

      // 主内容区域
      if (this.currentView === 'main') {
        this.MainContent()
      } else if (this.currentView === 'terminal') {
        this.TerminalContent()
      } else if (this.currentView === 'setup') {
        this.SetupContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#16213e')
  }

  @Builder
  MainContent() {
    Column() {
      // Logo 和欢迎信息
      Column() {
        Text('🧠')
          .fontSize(80)
          .margin({ bottom: 20 })
        
        Text('OpenClaw for HarmonyOS')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 12 })
        
        Text('AI Agent Platform on Your Device')
          .fontSize(16)
          .fontColor('#aaaaaa')
      }
      .margin({ top: 60 })

      // 功能卡片
      Column() {
        this.FeatureCard('📱', '终端模拟器', '完整的终端体验，支持多会话')
        this.FeatureCard('🤖', 'AI 助手', 'OpenClaw AI 平台集成')
        this.FeatureCard('🔧', '工具管理', '安装和管理开发工具')
        this.FeatureCard('📦', '引导安装', '一键配置开发环境')
      }
      .margin({ top: 40 })
      .width('90%')

      Blank()

      // 底部按钮
      Button() {
        Text(this.isInstalled ? '打开终端' : '开始安装')
          .fontSize(18)
          .fontColor(Color.White)
      }
      .width('90%')
      .height(50)
      .backgroundColor(this.isInstalled ? '#4CAF50' : '#2196F3')
      .borderRadius(25)
      .margin({ bottom: 40 })
      .onClick(() => {
        if (this.isInstalled) {
          this.currentView = 'terminal'
        } else {
          this.currentView = 'setup'
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FeatureCard(icon: string, title: string, desc: string) {
    Row() {
      Text(icon)
        .fontSize(32)
        .margin({ right: 16 })
      
      Column() {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .alignSelf(ItemAlign.Start)
        
        Text(desc)
          .fontSize(14)
          .fontColor('#888888')
          .margin({ top: 4 })
          .alignSelf(ItemAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#0f3460')
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  TerminalContent() {
    Column() {
      // 终端视图
      Column() {
        Text('Terminal View')
          .fontColor(Color.White)
          .fontSize(16)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#0a0a0a')
      
      // 额外按键栏
      Row() {
        Button('ESC')
          .fontSize(14)
          .backgroundColor('#333333')
          .fontColor(Color.White)
        Button('TAB')
          .fontSize(14)
          .backgroundColor('#333333')
          .fontColor(Color.White)
        Button('CTRL')
          .fontSize(14)
          .backgroundColor('#333333')
          .fontColor(Color.White)
        Button('ALT')
          .fontSize(14)
          .backgroundColor('#333333')
          .fontColor(Color.White)
      }
      .width('100%')
      .padding(8)
      .backgroundColor('#1a1a1a')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SetupContent() {
    Column() {
      Text('安装向导')
        .fontSize(24)
        .fontColor(Color.White)
        .margin({ top: 20, bottom: 20 })
      
      Text('正在配置环境...')
        .fontSize(16)
        .fontColor('#aaaaaa')
      
      Blank()
      
      Button('返回')
        .backgroundColor('#666666')
        .fontColor(Color.White)
        .margin({ bottom: 40 })
        .onClick(() => {
          this.currentView = 'main'
        })
    }
    .width('100%')
    .height('100%')
  }
}
