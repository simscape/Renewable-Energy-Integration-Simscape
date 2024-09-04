sCR.zfeeder=(feeder.r+2*pi*grid.frequency*1j*feeder.l)*feeder.length/base.z;
sCR.ztransformer=(windTransformer.windingResistance+1j*windTransformer.windingLekageReactance)*(windTransformer.va/base.mVA);
sCR.zline1=(line.r+2*pi*grid.frequency*1j*line.l*1e-3)*line.length1/base.z;
sCR.zline=(sCR.zline1)*(base.mVA/windTransformer.va);
sCR.SCR=abs(1/(sCR.zfeeder+sCR.ztransformer+sCR.zline));