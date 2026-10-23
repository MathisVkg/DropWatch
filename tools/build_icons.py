"""Build original vector/raster DropWatch icons. Development only: Pillow==12.3.0."""
from pathlib import Path
from PIL import Image, ImageDraw
import math

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"Assets"
TEAL="#58C4BD"; GOLD="#DDAA55"; DARK="#14191C"
def build(name,size,detailed):
    ss=4; n=size*ss
    image=Image.new("RGBA",(n,n))
    svg=['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 100 100">'%(size,size)]
    def paint(draw_fn,markup):
        layer=Image.new("RGBA",image.size); draw_fn(ImageDraw.Draw(layer)); image.alpha_composite(layer); svg.append(markup)
    def coords(values): return tuple(round(v*n/100) for v in values)
    def circle(x,y,r,fill=None,stroke=None,width=1):
        box=coords((x-r,y-r,x+r,y+r))
        paint(lambda d:d.ellipse(box,fill=fill,outline=stroke,width=max(1,round(width*n/100))),
              '<circle cx="%s" cy="%s" r="%s" fill="%s" stroke="%s" stroke-width="%s"/>'%(x,y,r,fill or "none",stroke or "none",width))
    def line(points,color,width):
        paint(lambda d:d.line([coords(p) for p in points],fill=color,width=max(1,round(width*n/100)),joint="curve"),
              '<polyline points="%s" fill="none" stroke="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"/>'%(" ".join("%s,%s"%p for p in points),color,width))
    def polygon(points,color):
        paint(lambda d:d.polygon([coords(p) for p in points],fill=color),
              '<polygon points="%s" fill="%s"/>'%(" ".join("%s,%s"%p for p in points),color))
    if detailed:
        paint(lambda d:d.rounded_rectangle(coords((0,0,100,100)),radius=round(n*.18),fill=DARK),
              '<rect width="100" height="100" rx="18" fill="%s"/>'%DARK)
    else: circle(50,50,49,DARK)
    circle(50,50,43,None,TEAL,4 if detailed else 6)
    # Minimal flat sweep sector: no gradients or glow.
    polygon([(50,50),(50,11),(69,16),(82,27)],"#203D3F")
    line([(50,50),(81,22)],TEAL,3 if detailed else 4.5)
    if detailed:
        circle(50,50,28,None,"#315C5D",1.6)
        circle(50,50,14,None,"#315C5D",1.4)
        for a in (0,90,180,270):
            rad=math.radians(a)
            line([(50+35*math.cos(rad),50+35*math.sin(rad)),(50+41*math.cos(rad),50+41*math.sin(rad))],TEAL,2)
        circle(27,66,3,TEAL)
        circle(70,68,2.5,TEAL)
    # Chunky equipment shield: a readable loot marker even at minimap/header size.
    polygon([(47,43),(65,43),(65,56),(56,66),(47,56)],GOLD)
    polygon([(51,47),(61,47),(61,54),(56,60),(51,54)],DARK)
    image=image.resize((size,size),Image.Resampling.LANCZOS)
    OUT.mkdir(exist_ok=True)
    image.save(OUT/(name+".png"))
    (OUT/(name+".svg")).write_text("\n".join(svg+["</svg>"])+"\n",encoding="utf-8")
    if not detailed:
        image.save(OUT/(name+".tga"),compression=None)
if __name__=="__main__":
    build("DropWatch-Project",1024,True)
    build("DropWatch-Mini",64,False)
    Image.open(OUT/"DropWatch-Project.png").resize((400,400),Image.Resampling.LANCZOS).save(OUT/"DropWatch-CurseForge.png")
    print("Built project/minimap assets plus a 400px portal PNG")
