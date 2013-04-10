__author__ = 'marrabld'
"""
!!! Under construction !!!
"""

import scipy.io
import pylab

class DimitriObject:

    def __init__(self):

        self.decimal_year = None
        self.sensor_zenith = None
        self.sensor_azimuth = None
        self.sun_zenith = None
        self.sun_azimuth = None
        self.ozone = None
        self.pressure = None
        self.relative_humidity = None
        self.wind_zonal = None
        self.wind_merid = None
        self.wvap = None
        self.bands = ['0b', '490p1', '490p2', '490p3', '443', '1020', '565', '670p1',
         '670p2', '670p3', '763', '765', '910', '865p1', '865p2','865p3'] # TODO maybe?
        #self.reflectance = scipy.zeros((1,9))
        #self.reflectance_std = scipy.zeros((1,9))

    def read_parasol_file(self, file = '/home/marrabld/projects/mosaec/Input/Site_DomeC/PARASOL/Proc_Calibration_1/PARASOL_TOA_REF.dat'):  # lint:ok

        num_bands = 9
        tmp = scipy.io.readsav(file, python_dict=True)
        tmp_dict = tmp['sensor_l1b_ref']

        self.decimal_year = tmp_dict[:,0]
        self.sensor_zenith = tmp_dict[:,1]
        self.sensor_azimuth = tmp_dict[:,2]
        self.sun_zenith = tmp_dict[:,3]
        self.sun_azimuth = tmp_dict[:,4]
        self.ozone = tmp_dict[:,5]
        self.pressure = tmp_dict[:,6]
        self.relative_humidity = tmp_dict[:,7]
        self.wind_zonal = tmp_dict[:,8]
        self.wind_merid = tmp_dict[:,9]
        self.wvap = tmp_dict[:,10]

        self.reflectance = tmp_dict[:,17:26]
        self.reflectance_std = tmp_dict[:,26:35]

    def plot_toa_reflectance(self, roi = [400], hold = 'off'):

        xdata = scipy.linspace(0, num_bands, num_bands)

        for i in range(len(roi)):
            pylab.errorbar(xdata, self.reflectance[roi[i],:], yerr=self.reflectance_std[roi[i],:])
            if hold == 'off':
                pylab.show()

        pylab.show()

if __name__== "__main__":
    dim_obj = DimitriObject()
    dim_obj.read_parasol_file()
    dim_obj.plot_toa_reflectance([400, 500, 560, 1000], hold = 'on')
    # TODO add more plotting stuff including axis (if you're watching john!!)'
    # TODO add metadata






