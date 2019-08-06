FROM ubuntu:18.04

RUN apt-get update && apt-get install -yy build-essential cmake locales git

# create locale for testing
RUN locale-gen nl_NL.UTF-8

RUN apt-get install -yy libtinyxml-dev libconsole-bridge-dev

RUN apt-get install -yy liburdfdom-headers-dev

RUN git clone https://github.com/ros/urdfdom.git && cd urdfdom && git fetch && git fetch --tags && git checkout 1.0.0

#checkout current version of test
RUN cd urdfdom && git checkout master -- urdf_parser/test/urdf_unit_test.cpp

RUN mkdir urdfdom_build && cd urdfdom_build && cmake ../urdfdom && make

#one unrelated test fails
RUN urdfdom_build/bin/urdf_unit_test; exit 0

# four (4) tests fail, parse* due to locale issues
RUN LANG=nl_NL.UTF-8 urdfdom_build/bin/urdf_unit_test ; exit 0

RUN git clone https://github.com/ros/urdfdom_headers.git

RUN mkdir urdfdom_headers_build && cd urdfdom_headers_build && cmake ../urdfdom_headers && make && make install

#rebuild urdfdom using urdfdom_headers 1.0.3
RUN cd urdfdom_build && rm -rf * && cmake ../urdfdom && make

#rerun tests again
#works for classic locale
RUN urdfdom_build/bin/urdf_unit_test

# three (3) tests fail, parse* due to locale issues
RUN LANG=nl_NL.UTF-8 urdfdom_build/bin/urdf_unit_test ; exit 0


#now also update urdfdom
RUN cd urdfdom && git checkout master && cd ../urdfdom_build && make

#rerun tests again
#works for classic locale
RUN urdfdom_build/bin/urdf_unit_test

# all tests succeed
RUN LANG=nl_NL.UTF-8 urdfdom_build/bin/urdf_unit_test
