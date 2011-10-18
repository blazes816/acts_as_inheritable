require "acts_as_inheritable/version"

ActiveRecord::Base.class_eval do
  def self.inheritance(type)
    extend MultipleTableInheritable if type == :multiple_table
  end
end

module MultipleTableInheritable
  # Handle being included.  Base is our new class, so do some Ruby magic to it
  def inherited(base)
    # Get the name of our parent model in AR friendly downcase
    parent = self.name.downcase
    
    # Set our table name, associations, and validations, and 
    # add a method_missing to delegate calls to the parent class
    base.instance_eval <<-RUBY
      set_table_name name.downcase.pluralize
      belongs_to :#{parent}, :autosave => true
      validate :#{parent}_must_be_valid
      
      def method_missing(meth, *args, &block)
        #{parent}.send(meth, *args, &block)
        rescue NoMethodError; super
      end
    RUBY
      
    # Start building instance methods, beginning with our parent autobuilder
    # which will be alias_method_chain'd after we eval these methods and
    # also create our validator to ensure all subclasses adhere to their
    # parent's validations
    instance_methods = <<-RUBY
      def #{parent}_with_build
        #{parent}_without_build || build_#{parent}
      end

      def #{parent}_must_be_valid
        unless #{parent}.valid?
          #{parent}.errors.each do |attr, message|
            errors.add(attr, message)
          end
        end
      end
    RUBY
    
    # Create accessor methods for parent attributes.  Get parent's columns
    # subtrace our default columns, then add proper accessors for each
    begin
      all = base.superclass.content_columns.map(&:name)
    rescue ActiveRecord::StatementInvalid, Mysql::Error
      all = []
    end

    attributes = all - ["created_at", "updated_at", "person_type"]
    attributes.map! do |attrib| 
      <<-RUBY
        def #{attrib};            #{parent}.#{attrib};          end
        def #{attrib}=(value);    #{parent}.#{attrib} = value;  end
        def #{attrib}?;           #{parent}.#{attrib}?;         end
      RUBY
    end
    
    # Append the array of method definitions
    instance_methods += attributes.join('')
    
    # Eval our instance_methods
    base.class_eval(instance_methods)
    base.alias_method_chain parent, :build
  end
end
