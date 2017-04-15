FROM ruby:2.1

# RUN gem install rubygems
# RUN gem install csv
# RUN gem install kconv
RUN gem install vpim

RUN mkdir /work
WORKDIR /work

