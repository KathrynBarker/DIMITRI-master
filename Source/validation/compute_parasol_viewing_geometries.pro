function compute_parasol_viewing_geometries,pvza,praa,pdvzc,pdvzs,order=order

; use order keyword to put the new angles in ascending wavelength order


  xj = [-6.,-4.,-3.,-2.,0.,2.,3.,4.,6.]

;convert degrees to radians

  rvza = !DTOR*pvza
  rraa = !DTOR*praa
  rdvzc= !DTOR*pdvzc
  rdvzs= !DTOR*pdvzs

  var1 = (rvza*cos(rraa))+(xj*rdvzc)
  var2 = (rvza*sin(rraa))+(xj*rdvzs)

  nvza = sqrt((var1^2)+(var2^2))
  nraa = atan(var2/var1)

; convert back to degrees

  nvza = !RADEG*nvza
  nraa = !RADEG*nraa

  temp = where(var1 lt 0.0,count)
  if count gt 0 then nraa[temp] = nraa[temp]+180.

  if keyword_set(order) then begin
  temp = [1,0,3,4,5,6,8,7,2]
  nvza = nvza[temp]
  nraa = nraa[temp]
  endif

; return the angle data

  return,{vza:nvza,raa:nraa}

end