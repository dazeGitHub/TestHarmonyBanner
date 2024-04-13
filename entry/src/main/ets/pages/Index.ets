import { SwiperComponent } from '../components/SwiperComponent'
import { SwiperComponentHalfFold } from '../components/SwiperComponentHalfFold'
import { SwiperComponentThreeEle } from '../components/SwiperComponentThreeEle'

@Entry
@Component
struct Index {
  @State message: string = 'Hello World'

  build() {
    Row() {
      Column() {
        // SwiperComponent()
        // SwiperComponentThreeEle()
        SwiperComponentHalfFold()
      }
      .width('100%')
    }
    .height('100%')
  }
}