import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'OpenClaw', 'Ability onCreate');
  }

  onDestroy(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'OpenClaw', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'OpenClaw', 'Ability onWindowStageCreate');

    // 设置主窗口
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'OpenClaw', 'Failed to load content. Cause: %{public}s', 
          JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'OpenClaw', 'Succeeded in loading content. Data: %{public}s',
        JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'OpenClaw', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'OpenClaw', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'OpenClaw', 'Ability onBackground');
  }
}
