FC = gfortran

FCFLAGS = -c

DEBUGFLAGS = -O

#LIB = -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib


OBJ2 =    radar5.f dc_decdel.f decsol.f contr5.f spline.f splint.f dontr5.f
OBJ1 =    driver_baroreflex.f

prog :  $(OBJ1) 
	$(FC) $(DEBUGFLAGS) -o driver $(OBJ1) $(OBJ2) -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib



