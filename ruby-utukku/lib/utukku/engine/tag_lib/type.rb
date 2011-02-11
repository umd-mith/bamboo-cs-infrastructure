class Utukku::Engine::TagLib::Type
  def initialize(t)
    @type = t
    @goings = { }
    @comings = { }
    @methods = { }
  end

  def vtype
    @type
  end

  def going_to(t, &block)
    return unless block
    @goings[t.join('')] ||= [ ]
    obj = Utukku::Engine::TagLib::TypeConversion.new(t)
    obj.instance_eval &block
    @goings[t.join('')] = obj
  end

  def coming_from(t, &block)
    return unless block
    @comings[t.join('')] ||= [ ]
    obj = Utukku::Engine::TagLib::TypeConversion.new(t)
    obj.instance_eval &block
    @comings[t.join('')] = obj
  end

  def outgoing_conversions
    @goings
  end

  def incoming_conversions
    @comings
  end

  def method(nom, &block)
    @methods[@type[0] + nom.to_s] = block
  end

  def get_method(nom)
    @methods[nom]
  end

  def build_conversion_to(to)
    return [] if to.nil? || self == to
    ut = self._unify_types(to, true)
    return [] if ut.nil? || ut[:t].nil? || ut[:t].vtype.join('') != to.join('')
    return ut[:convert]
  end

  def unify_with_type(t)
    self._unify_types(t)
  end

protected

  def _unify_types(to, ordered = false)
    return nil if to.nil?
    if to.is_a?(Array)
      to = Utukku::Engine::TagLib.type_handler(to)
      return nil if to.nil?
    end

    d1 = { @type.join('') => { :t => self, :w => 1.0, :path => [ self ], :convert => [ ] } }
    d2 = { to.vtype.join('') => { :t => to, :w => 1.0, :path => [ to ], :convert => [ ] } }
   
    added = true
    while added
      added = false
      [d1, d2].each do |d|
        d.keys.each do |t|
          if !d[t][:t].nil?
            d[t][:t].outgoing_conversions.each_pair do |conv_key, conv|
              #conv_key = conv.vtype.join('')
              w = d[t][:w] * conv.weight
              if d.has_key?(conv_key)
                if d[conv_key][:w] < w
                  d[conv_key][:w] = w
                  d[conv_key][:path] = d[t][:path] + [ conv.vtype ]
                  d[conv_key][:convert] = d[t][:convert] + [ conv ] - [nil]
                end
              else
                added = true
                d[conv_key] = {
                  :t => conv.vtype.is_a?(Array) ? Utukku::Engine::TagLib.type_handler(conv.vtype) : conv.vtype,
                  :w => w,
                  :path => d[t][:path] + [ conv.vtype ],
                  :convert => d[t][:convert] + [ conv ] - [nil],
                }
              end
            end
          end
        end
        Utukku::Engine::TagLib.types.keys.each do |ns|
          Utukku::Engine::TagLib.types[ns].each_pair do |ct, tob|
            to_key = ns + ct.to_s
            tob.incoming_conversions.each_pair do |from_key, conv|
              #from_key = conv.vtype.join('')
              next unless d.has_key?(from_key)
              w = d[from_key][:w] * conv.weight
              if d.has_key?(to_key)
                if d[to_key][:w] < w
                  d[to_key][:w] = w
                  d[to_key][:path] = d[from_key][:path] + [ conv.vtype ]
                  d[to_key][:convert] = d[from_key][:convert] + [ conv ]
                end
              else
                added = true
                d[to_key] = {
                  :t => Utukku::Engine::TagLib.type_handler([ ns, ct ]),
                  :w => w * 95.0 / 100.0,
                  :path => d[from_key][:path] + [ conv.vtype ],
                  :convert => d[from_key][:convert] + [ conv ],
                }
              end
            end
          end
        end
      end
      r = self._select_type_path(d1, d2, to, ordered)
      return r unless r.nil?
    end
    return self._select_type_path(d1, d2, to, ordered)
  end

  def _select_type_path(d1, d2, t2, ordered)
    common = d1.keys & d2.keys
    if ordered && common.include?(t2.vtype.join(''))
      return d1[t2.vtype.join('')]
    elsif !common.empty?
      return d1[common.sort_by{ |c| d1[c][:w] * d2[c][:w] / d1[c][:path].size / d2[c][:path].size }.reverse.first]
    end
    return nil
  end
end

class Utukku::Engine::TagLib::TypeConversion
  def initialize(t)
    @type = t
    @weight = 0.0
     @guard = nil
  end

  def vtype
    @type
  end

  def weight(w = nil)
    @weight = w unless w.nil?
    @weight
  end

   def guard(&block)
     if !block.nil?
       @guard = block
     end
   end

  def converting(&block)
    @conversion = block
  end

  def convert(v)
    return v.root.anon_node(nil) if @conversion.nil?
    @conversion.call(v)
  end

  def can_convert?(v)
    return true if @guard.nil?
    @guard.call(v)
  end
end

