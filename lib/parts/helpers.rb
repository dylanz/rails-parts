module Parts
  module Helpers
    def part(opts = {})
      klasses, opts = opts.partition do |k,v|
        k.respond_to?(:ancestors) && k.ancestors.include?(Parts::Base)
      end

      opts = opts.inject({}) {|h,v| h[v.first] = v.last; h}

      res = klasses.inject([]) do |memo,(klass,action)|
        part = klass.new(self, opts)

        # push in the specific parts custom view path
        part.view_paths << "#{Rails.root}/app/parts/#{part._prefix}/views"

        ## FIXME:  So close but so far...  using frozen_formats to determine if a part is rendered
        #  from a view or from a controller, in order to get the view lookup path accurate.
        #  Almost working, but, frozen_formats isn't the answer, as it's frozen_formats
        #  ends up being counter to what was expected
        if self.lookup_context.instance_variable_get(:@frozen_formats) == true
          ActionView::PathSet.instance_eval do
            define_method :find, ->(path, prefix = nil, partial = false, details = {}, key = nil) do
              prefix = ""
              template = find_all(path, prefix, partial, details, key).first
              raise ActionView::MissingTemplate.new(self, "#{prefix}/#{path}", details, partial) unless template
              template
            end
          end
        end

        part.process(action)
        memo << part.response_body
      end

      res.size == 1 ? res[0] : res
    end
  end
end
