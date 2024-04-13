import { SwiperComponent } from '../components/SwiperComponent'
import { SwiperComponentThreeEle } from '../components/SwiperComponentThreeEle'

@Entry
@Component
struct Index {
  @State message: string = 'Hello World'

  build() {
    Row() {
      Column() {
        // SwiperComponent()
        SwiperComponentThreeEle()
      }
      .width('100%')
    }
    .height('100%')
  }
}