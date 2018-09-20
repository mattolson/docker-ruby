FROM mattolson/base

ENV RUBY_MAJOR 2.5
ENV RUBY_VERSION 2.5.1

RUN apt-get update &&\
	  apt-get install -y --no-install-recommends \
      libffi-dev \
      libgdbm-dev \
      libncurses-dev \
      libreadline6-dev \
      libssl-dev \
      # Note libssl 1.0 required for Ruby 2.3
      #libssl1.0-dev \
      libyaml-dev \
      zlib1g-dev &&\
	  apt-get clean

RUN mkdir -p /usr/src/ruby &&\
	  curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" &&\
	  tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 &&\
	  rm ruby.tar.gz &&\
	  cd /usr/src/ruby &&\
	  ./configure --disable-install-doc &&\
	  make -j"$(nproc)" &&\
	  make install &&\
	  rm -rf /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_BIN $GEM_HOME/bin

RUN gem install bundler pry

ENTRYPOINT ["pry"]
