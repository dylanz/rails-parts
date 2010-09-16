module Parts
  module Helpers

    ## TODO:  Rendering from a Part from a controller works fine, but rendering
    ##        one from a view does not.  There is a path issue when looking up
    ##        views from the main application vs Part paths.
    #def strip_path_prefix(prefix, &block)
    #  unless self.lookup_context.instance_variable_get(:@frozen_formats) == true
    #    AbstractController::Rendering.instance_eval { def _prefix; "" end }
    #    yield
    #    AbstractController::Rendering.instance_eval { def _prefix; prefix end }
    #  end
    #end

    def part(opts = {})
      klasses, opts = opts.partition do |k,v|
        k.respond_to?(:ancestors) && k.ancestors.include?(Parts::Base)
      end

      opts = opts.inject({}) {|h,v| h[v.first] = v.last; h}

      res = klasses.inject([]) do |memo,(klass,action)|
        part = klass.new(self, opts)
        part.process(action)

        #strip_path_prefix(self._prefix) { part.process(action) }
        memo << part.response_body
      end

      res.size == 1 ? res[0] : res
    end
  end
end
