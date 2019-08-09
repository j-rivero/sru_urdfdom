FROM ubuntu:18.04

RUN echo 'echo # BEGIN SECTION: setup test case'
RUN apt-get update && apt-get install -yy build-essential cmake locales git software-properties-common

# create locale for testing
RUN locale-gen nl_NL.UTF-8
RUN apt-get install -yy libtinyxml-dev libconsole-bridge-dev liburdfdom-headers-dev liburdfdom-dev
RUN git clone https://github.com/ros/urdfdom.git && cd urdfdom && git fetch && git fetch --tags && git checkout 1.0.0
#checkout current version of test
RUN cd urdfdom && git checkout master -- urdf_parser/test/urdf_unit_test.cpp
RUN mkdir urdfdom_build && cd urdfdom_build && cmake ../urdfdom/urdf_parser/test/ && make
RUN echo '# END SECTION'

RUN echo 'echo # BEGIN SECTION: failing tests with urdfdom header from Bionic'
#one unrelated test fails
RUN urdfdom_build/urdf_unit_test; exit 0
# four (4) tests fail, parse* due to locale issues
RUN LANG=nl_NL.UTF-8 urdfdom_build/urdf_unit_test ; exit 0
RUN echo '# END SECTION'

# Install new urdfdom package
RUN echo 'echo # BEGIN SECTION: install patche PPA version of urdfdom pkgs'
RUN add-apt-repository ppa:j-rivero/urdfdom-headers-sru2
RUN apt-get update && apt-get install -yy liburdfdom-headers-dev liburdfdom-dev
RUN echo '# END SECTION'

ARG CACHE_DATE=not_a_date
#rebuild urdfdom using urdfdom_headers 1.0.3
RUN echo 'echo # BEGIN SECTION: rebuild test'
RUN cd urdfdom && git fetch && git fetch --tags && git checkout master
RUN cd urdfdom_build && rm -rf * && cmake ../urdfdom/urdf_parser/test/ && make
RUN echo '# END SECTION'

RUN echo 'echo # BEGIN SECTION: good tets with new urdfdom header package'
RUN urdfdom_build/urdf_unit_test
RUN LANG=nl_NL.UTF-8 urdfdom_build/urdf_unit_test
RUN echo '# END SECTION'
