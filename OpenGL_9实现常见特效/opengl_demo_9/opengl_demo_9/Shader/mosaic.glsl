precision mediump float;

varying vec2 vTexcoord;
uniform sampler2D image;
const vec2 TexSize = vec2(150.0, 150.0);
const vec2 mosaicSize = vec2(8.0, 8.0);

//马赛克效果就是把图片的一个相当大小的区域用同一个点的颜色来表示.
//可以认为是大规模的降低图像的分辨率,而让图像的一些细节隐藏起来。

void main()
{
    vec2 intXY = vec2(vTexcoord.x*TexSize.x, vTexcoord.y*TexSize.y);
    // floor 向下取整 ceil 向上取整
    vec2 XYMosaic  = vec2(floor(intXY.x/mosaicSize.x)*mosaicSize.x, floor(intXY.y/mosaicSize.y)*mosaicSize.y);
    vec2 UVMosaic = vec2(XYMosaic.x/TexSize.x, XYMosaic.y/TexSize.y);
    
    vec4 color = texture2D(image, UVMosaic);
    gl_FragColor = color;
}
