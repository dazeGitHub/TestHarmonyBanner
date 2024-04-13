import { SwiperData } from '../model/SwiperData';
import Logger from '../utils/Logger';

/**
 * 层叠轮播图组件
 * 是 SwiperComponent 的修改版, 只显示右侧的折叠部分
 */
@Component
export struct SwiperComponentHalfFold {
  @State currentIndex: number = 0;
  @State swiperData: SwiperData[] = [
    new SwiperData($r("app.media.mp_chart"), 'MpChart图表实现案例'),
    new SwiperData($r("app.media.lottie"), 'Lottie动画'),
    new SwiperData($r("app.media.component_tack"), '组件堆叠'),
    new SwiperData($r("app.media.ic_swiper1"), '轮播1'),
    new SwiperData($r("app.media.ic_swiper2"), '轮播2'),
    new SwiperData($r("app.media.ic_swiper3"), '轮播3'),
  ];
  private halfCount: number = Math.floor(6 / 2);  //半数 = 总数 / 2
  private manualSlidingDuration: number = 800;    //手动滑动时长
  private automaticSlidingDuration: number = 300;
  private automaticSwitchTime: number = 5000;
  private offsetXValue = 15;
  @State swiperInterval: number = 0

  aboutToAppear(): void {
    this.currentIndex = this.halfCount;
    this.swiperInterval = setInterval(() => {
      this.startAnimation(true, this.manualSlidingDuration);
    }, this.automaticSwitchTime);
  }

  /**
   * 获取图片系数
   * @param index：索引值
   * @returns
   */
  getImgCoefficients(index: number): number {
    const coefficient: number = this.currentIndex - index; // 计算图片左右位置
    const tempCoefficient: number = Math.abs(coefficient);
    if (tempCoefficient <= this.halfCount) {
      return coefficient;
    }
    const dataLength: number = this.swiperData.length;
    let tempOffset: number = dataLength - tempCoefficient; // 判断图片位于左右层级位置
    if (tempOffset <= this.halfCount) { //如果在左侧
      if (coefficient > 0) {
        return -tempOffset;
      }
      return tempOffset;
    }
    return 0;
  }

  /**
   * 计算偏移量
   * @param index：索引值
   * @returns
   */
  getOffSetX(index: number): number {
    const offsetIndex: number = this.getImgCoefficients(index);
    const tempOffset: number = Math.abs(offsetIndex);
    let offsetX: number = 0;
    if (tempOffset === 1) {
      // 根据图片层级系数来决定左右偏移量
      offsetX = -15 * offsetIndex;
    }
    if (tempOffset === 2) {
      // 根据图片层级系数来决定左右偏移量
      offsetX = -this.offsetXValue * offsetIndex;
    }
    Logger.info("TAG", "index = " + index + " offsetX = " + offsetX)
    return offsetX;
  }

  // 性能：显式动画(https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-explicit-animation-0000001478341181-V2)
  startAnimation(isLeft: boolean, duration: number): void {
    animateTo({
      duration: duration,
    }, () => {
      const dataLength: number = this.swiperData.length;
      const tempIndex: number = isLeft ? this.currentIndex + 1 : this.currentIndex - 1 + dataLength;
      this.currentIndex = tempIndex % dataLength;
    })
  }

  build() {
    Column() {
      Stack() {
        // LazyForEach必须在容器组件内使用，仅有List、Grid、Swiper以及WaterFlow组件支持数据懒加载，其他组件仍然是一次性加载所有的数据。
        ForEach(this.swiperData, (item: SwiperData, index: number) => {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(item.imageSrc)
              .objectFit(ImageFit.Cover)
              .width('100%')
              .height('100%')
              .borderRadius($r('app.string.main_page_top_borderRadius'))
            // 轮播图底部蒙层 必定在上方
            Stack() {
              Column() {
              }
              .width('100%')
              .height('100%')
              .backgroundColor(Color.Black)
              .opacity(0.3)
              .borderRadius({
                topLeft: 0,
                topRight: 0,
                bottomLeft: $r('app.string.main_page_top_borderRadius'),
                bottomRight: $r('app.string.main_page_top_borderRadius')
              })

              Text(item.name)
                .width('100%')
                .height('100%')
                .fontSize(16)
                .fontColor(Color.White)
                .textAlign(TextAlign.Start)
                .padding($r('app.string.main_page_padding5'))
            }
            .height($r('app.string.bottom_title_height'))
          }
          .backgroundColor(Color.White)
          .borderRadius(8)
          .offset({
            x: this.getOffSetX(index),
            y: 0
          })
          .blur(index !== this.currentIndex ? 12 : 0)
          // TODO: 知识点:通过animateTo实现动画并且同时改变currentIndex数据中间值来判断组件zIndex实现切换动画
          .zIndex(index !== this.currentIndex && this.getImgCoefficients(index) === 0 ?
            0 : 2 - Math.abs(this.getImgCoefficients(index)))
          .width($r('app.string.swiper_stack_width'))
          // .height(index !== this.currentIndex ? $r('app.string.swiper_stack_height1') : $r('app.string.swiper_stack_height2'))
          .height(
            index === this.currentIndex ?
              $r("app.string.swiper_stack_height1")
              : ((index === this.currentIndex - 1 || index === this.currentIndex + 1) ?
                $r("app.string.swiper_stack_height2") :
                $r("app.string.swiper_stack_height3"))
          )
          .onClick(() => {
            // 点击轮播图Item时，根据点击的模块信息，将页面放入路由栈
            // DynamicsRouter.push(item.routerInfo, item.param);
          })
        })
      }
      .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
        clearInterval(this.swiperInterval);
        if (isVisible && currentRatio >= 1.0) {
          this.swiperInterval = setInterval(() => {
            this.startAnimation(true, this.manualSlidingDuration);
          }, this.automaticSwitchTime)
        }

        if (!isVisible && currentRatio <= 0.0) {
          clearInterval(this.swiperInterval);
        }
      })
      //高度必须和 app.string.swiper_stack_height1 相同
      .height($r('app.string.swiper_stack_height1'))
      .width('100%')
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart((event: GestureEvent) => {
            clearInterval(this.swiperInterval);
            this.startAnimation(event.offsetX < 0, this.automaticSlidingDuration);
          })
          .onActionEnd(() => {
            this.swiperInterval = setInterval(() => {
              this.startAnimation(true, this.manualSlidingDuration);
            }, this.automaticSwitchTime);
          })
      )
      .alignContent(Alignment.Start)
      .backgroundColor($r("app.color.green"))
      .clip(true) //裁剪超出 banner 左侧的层叠部分
      .margin({left: "100vp"})
      // .margin({left: -this.offsetXValue * 2}) //整体左移动两个位移

      //底部指示器
      Row({ space: 10 }) {
        ForEach(this.swiperData, (item: SwiperData, index: number) => {
          Ellipse(index !== this.currentIndex ? { width: 8, height: 8 } : { width: 10, height: 8 })
            .fill(index !== this.currentIndex ? Color.Black : Color.Red)
            .fillOpacity(0.6)
        })
      }
      .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.blue"))
    .justifyContent(FlexAlign.Start)
  }
}
