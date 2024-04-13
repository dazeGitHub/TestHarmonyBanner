export class SwiperData {
  imageSrc: Resource;
  name: string;
  param: string;

  constructor(imageSrc: Resource, name: string) {
    this.imageSrc = imageSrc;
    this.name = name;
  }
}