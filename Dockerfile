FROM mattolson/base

ENV RUBY_MAJOR 2.0
ENV RUBY_VERSION 2.0.0-p643

RUN apt-get update &&\
	apt-get install -y --no-install-recommends \
  libffi-dev \
  libgdbm-dev \
  libncurses-dev \
  libreadline6-dev \
  libssl-dev \
  libyaml-dev \
  zlib1g-dev &&\
	rm -rf /var/lib/apt/lists/* &&\
	mkdir -p /usr/src/ruby &&\
	curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" &&\
	tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 &&\
	rm ruby.tar.gz &&\
	cd /usr/src/ruby &&\
	./configure --disable-install-doc &&\
	make -j"$(nproc)" &&\
	make install &&\
	rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler pry &&\
	  bundle config --global path "$GEM_HOME" &&\
	  bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

CMD ["pry"]