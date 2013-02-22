require EnjuTrunkCirculation::Engine.root.join('app', 'models', 'ability') if Setting.operation
class Ability
  include CanCan::Ability

  def initialize(user, ip_address = nil)
    initialize_circulation(user) if Setting.operation
    case user.try(:role).try(:name)
    when 'Administrator'
      can [:read, :create, :update], AcceptType
      can :destroy, AcceptType do |accept_type|
        accept_type.items.count == 0
      end
      can [:read, :create, :update], Bookstore
      can :destroy, Bookstore do |bookstore|
        bookstore.order_lists.empty?
      end
      can [:read, :create, :update], Budget
      can :destroy, Budget do |budget|
        budget.expenses.empty?
      end
      can [:read, :create, :update], BudgetType
      can :destroy, BudgetType do |budget_type|
        budget_type.budgets.empty?
      end
      can [:read, :create, :update], ClassificationType
      can :destroy, ClassificationType do |classification_type|
        classification_type.classifications.empty?
      end
      can [:read, :create, :export_loan_lists, :get_loan_lists, :pickup, :pickup_item, :accept, :accept_item, :download_file, :output], InterLibraryLoan
      can [:update, :destroy], InterLibraryLoan do |inter_library_loan|
        inter_library_loan.state == "pending" || inter_library_loan.state == "requested"
      end
      can [:read, :create, :update, :remove, :restore], Item
      can :destroy, Item do |item|
        item.deletable?
      end      
      can [:read, :create, :update], Library
      can :destroy, Library do |library|
        #library.shelves.empty? and library.users.empty? and library.budgets.empty? and library.events.empty? and !library.web?
        library.id != 0 and  library.shelves.size == 1 and library.shelves[0].open_access == 9 and library.shelves[0].items.empty? and library.budgets.empty? and library.events.empty? and !library.web?
      end
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        manifestation.items.empty? and Setting.operation and !manifestation.is_reserved?
      end
      can [:read, :create, :update], SeriesStatement
      can :destroy, SeriesStatement do |series_statement|
        if series_statement.periodical
          series_statement.manifestations.size == 1 and series_statement.manifestations[0].periodical_master
        else
          series_statement.manifestations.empty?
        end
      end
      can [:read, :create, :update], Patron
      can :destroy, Patron do |patron|
        if patron.user
          patron.user.checkouts.not_returned.empty?
        else
          true
        end
      end
      can [:read, :create, :output], Shelf
      can :update, Shelf do |shelf|
        shelf.open_access < 9
      end
      can :destroy, Shelf do |shelf|
        shelf.items.count == 0
      end
      can [:read, :create, :update], RetentionPeriod
      can :destroy, RetentionPeriod do |retention_period|
        retention_period.items.empty?
      end 
      can [:read, :create, :update], RemoveReason
      can :destroy, RemoveReason do |remove_reason|
        remove_reason.items.count == 0
      end
      can [:read, :create, :update], User
      can :destroy, User do |u|
        u.deletable? and u != user
      end
      can [:read, :create, :update], UserGroup
      can :destroy, UserGroup do |user_group|
        user_group.users.empty?
      end
      can :manage, [
        AccessLog,
        Answer,
        Barcode,
        BarcodeList,
        BindingItem,
        Bookbinding,
        CarrierTypeHasCheckoutType,
        Checkoutlist,
        CheckoutStatHasManifestation,
        CheckoutStatHasUser,
        CheckoutType,
        Classification,
        Classmark,
        Create,
        CreateType,
        Department,
        Donate,
        Exemplify,
        Expense,
        Family,
        ImportRequest,
        Inventory,
        InventoryFile,
        ItemHasUseRestriction,
        KeywordCount,
        LibcheckDataFile,
        LibraryCheck,
        LibraryCheckShelf,
        LibraryReport,
        ManifestationCheckoutStat,
        ManifestationRelationship,
        ManifestationRelationshipType,
        ManifestationReserveStat,
        Numbering,
        Order,
        OrderList,
        Own,
        PatronImportFile,
        PatronMerge,
        PatronMergeList,
        PatronRelationship,
        PatronRelationshipType,
        PictureFile,
        Produce,
        ProduceType,
        PurchaseRequest,
#        Question,
        Realize,
        RealizeType,
        ReserveStatHasManifestation,
        ReserveStatHasUser,
        ResourceImportFile,
        ResourceImportTextfile,
        SearchEngine,
        SearchHistory,
        SeriesStatementRelationship,
        SeriesHasManifestation,
        SeriesStatementMerge,
        SeriesStatementMergeList,
        Subject,
        SubjectHasClassification,
        SubjectHeadingType,
        SubjectHeadingTypeHasSubject,
        SubjectType,
        Subscribe,
        Subscription,
        SystemConfiguration,
        Term,
        EnjuTerminal,
        UserCheckoutStat,
        UserGroupHasCheckoutType,
        UserHasRole,
        UserReserveStat,
        UserStatus,
        WorkHasSubject
      ]
      can [:read, :update], [
        AcceptType,
        CarrierType,
        CirculationStatus,
        ContentType,
        Country,
        Extent,
        Frequency,
        FormOfWork,
        Language,
        LibraryGroup,
        License,
        ManifestationType,
        MediumOfPerformance,
        PatronType,
        RequestStatusType,
        RequestType,
        Role,
        UseRestriction
      ]
      can :read, [
        PatronImportResult,
        ResourceImportResult,
        ResourceImportTextresult,
        UserRequestLog
      ]
    when 'Librarian'
      can [:read, :create, :update], Budget
      can :destroy, Budget do |budget|
        budget.expenses.empty?
      end
      can [:read, :create, :update], BudgetType
      can :destroy, BudgetType do |budget_type|
        budget_type.budgets.empty?
      end
      can [:read, :create, :export_loan_lists, :get_loan_lists, :pickup, :pickup_item, :accept, :accept_item, :download_file, :output], InterLibraryLoan
      can [:update, :update, :destroy], InterLibraryLoan do |inter_library_loan|
        inter_library_loan.state == "pending" || inter_library_loan.state == "requested"
      end
      can [:read, :create, :update, :remove, :restore], Item
      can :destroy, Item do |item|
        item.deletable?
      end
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        manifestation.items.empty? and !manifestation.is_reserved?
      end
      can [:read, :create, :update], SeriesStatement
      can :destroy, SeriesStatement do |series_statement|
        if series_statement.periodical
          series_statement.manifestations.size == 1 and series_statement.manifestations[0].periodical_master == false
        else
          series_statement.manifestations.empty?
        end
      end
      can [:output], Shelf
      can [:index, :create], Patron
      can :show, Patron do |patron|
        patron.required_role_id <= 3
      end
      can [:update, :destroy], Patron do |patron|
        !patron.user.try(:has_role?, 'Librarian') and patron.required_role_id <= 3
      end
      can [:index, :create], PurchaseRequest
      can [:index, :create], PurchaseRequest
      can [:show, :update, :destroy], PurchaseRequest do |purchase_request|
        purchase_request.user == user
      end
      can [:index, :create], Question
      can [:update, :destroy], Question do |question|
        question.user == user
      end
      can :show, Question do |question|
        question.user == user or question.shared
      end
#      can [:update, :destroy, :show], Reserve do |reserve|
#        reserve.try(:user) == user
#      end
      can :index, SearchHistory
      can [:show, :destroy], SearchHistory do |search_history|
        search_history.user == user
      end
      can [:read, :create, :update], User
      can :destroy, User do |u|
        u.checkouts.not_returned.empty? and (u.role.name == 'User' || u.role.name == 'Guest') and u != user
      end
      can [:read, :create, :update], UserCheckoutStat
      can [:read, :create, :update], UserReserveStat
      can [:read, :create, :update], RemoveReason
      can :destroy, RemoveReason do |remove_reason|
        remove_reason.items.count == 0
      end
      can :manage, [
        AccessLog,
        Answer,
        Barcode,
        BarcodeList,
        BindingItem,
        Bookbinding,
        Checkoutlist,
        Classmark,
        Create,
        CreateType,
	      Department,
        Donate,
        Exemplify,
        Expense,
        Family,
        ImportRequest,
        Inventory,
        InventoryFile,
        KeywordCount,
        LibcheckDataFile,
        LibraryCheck,
        LibraryCheckShelf,
        LibraryReport,
        ManifestationCheckoutStat,
        ManifestationRelationship,
        ManifestationReserveStat,
        Numbering,
        Order,
        OrderList,
        Own,
        PatronImportFile,
        PatronMerge,
        PatronMergeList,
        PatronRelationship,
        PictureFile,
        Produce,
        ProduceType,
        PurchaseRequest,
        Question,
        Realize,
        RealizeType,
        ResourceImportFile,
        ResourceImportTextfile,
        SearchHistory,
        SeriesStatementRelationship,
        SeriesHasManifestation,
        SeriesStatementMerge,
        SeriesStatementMergeList,
        SubjectHasClassification,
        Subscribe,
        Subscription,
        SystemConfiguration,
        Term,
        UserStatus,
        WorkHasSubject
      ]
      can :read, [
        AcceptType,
        Bookstore,
        CarrierType,
        CarrierTypeHasCheckoutType,
        CheckoutType,
        CheckoutStatHasManifestation,
        CheckoutStatHasUser,
        CirculationStatus,
        Classification,
        ClassificationType,
        ContentType,
        Country,
        Extent,
        Frequency,
        FormOfWork,
        ItemHasUseRestriction,
        Language,
        Library,
        LibraryGroup,
        License,
        ManifestationType,
        ManifestationRelationshipType,
        MediumOfPerformance,
        PatronImportResult,
        PatronRelationshipType,
        PatronType,
        RequestStatusType,
        RequestType,
        ReserveStatHasManifestation,
        ReserveStatHasUser,
        ResourceImportResult,
        ResourceImportTextresult,
        RetentionPeriod,
        Role,
        SearchEngine,
        Shelf,
        Subject,
        SubjectType,
        SubjectHeadingType,
        SubjectHeadingTypeHasSubject,
        EnjuTerminal,
        UseRestriction,
        UserGroup,
        UserGroupHasCheckoutType,
        UserRequestLog
      ]
    when 'User'
      can [:index, :create], Answer
      can :show, Answer do |answer|
        if answer.user == user
          true
        elsif answer.question.shared
          answer.shared
        end
      end
      can [:update, :destroy], Answer do |answer|
        answer.user == user
      end
      can :index, Item
      can :show, Item do |item|
        item.required_role_id <= 2
      end
      can :read, Manifestation do |manifestation|
        manifestation.required_role_id <= 2
      end
      can :edit, Manifestation
      can [:index, :create], Question
      can [:update, :destroy], Question do |question|
        question.user == user
      end
      can :show, Question do |question|
        question.user == user or question.shared
      end
      can [:index, :create], Patron
      can :update, Patron do |patron|
        patron.user == user
      end
      can :show, Patron do |patron|
        if patron.user == user
          true
        elsif patron.user != user
          true if patron.required_role_id <= 2 #name == 'Administrator'
        end
      end
      can :index, PictureFile
      can :show, PictureFile do |picture_file|
        begin
          true if picture_file.picture_attachable.required_role_id <= 2
        rescue NoMethodError
          true
        end
      end
      can [:index, :create, :show], PurchaseRequest
      can [:update, :destroy], PurchaseRequest do |purchase_request|
        purchase_request.user == user
      end
      can :index, SearchHistory
      can [:show, :destroy], SearchHistory do |search_history|
        search_history.user == user
      end
      can :show, User
      can :update, User do |u|
        u == user
      end
      can :read, [
        AcceptType,
        CarrierType,
        CirculationStatus,
        Classification,
        ClassificationType,
        Classmark,
        ContentType,
        Country,
        Create,
        CreateType,
	      Department,
        Exemplify,
        Extent,
        Frequency,
        FormOfWork,
        Language,
        Library,
        LibraryGroup,
        License,
        ManifestationRelationship,
        ManifestationRelationshipType,
        ManifestationCheckoutStat,
        ManifestationReserveStat,
        MediumOfPerformance,
        Own,
        PatronRelationship,
        PatronRelationshipType,
        Produce,
        ProduceType,
        Realize,
        RealizeType,
        RemoveReason,
        SeriesStatement,
        SeriesHasManifestation,
        Shelf,
        Subject,
        SubjectHasClassification,
        SubjectHeadingType,
        EnjuTerminal,
        UserCheckoutStat,
        UserReserveStat,
        UserStatus,
        UserGroup,
        WorkHasSubject
      ]
    else
      can :index, Patron
      can :show, Patron do |patron|
        patron.required_role_id == 1 #name == 'Guest'
      end
      can :read, Manifestation do |manifestation|
        manifestation.required_role_id <= 1
      end
      can [:index, :create, :show], PurchaseRequest if SystemConfiguration.get('internal_server')
      can :read, [
        CarrierType,
        CirculationStatus,
        Classification,
        ClassificationType,
        Classmark,
        ContentType,
        Country,
        Create,
        CreateType,
        Exemplify,
        Extent,
        Frequency,
        FormOfWork,
        Item,
        Language,
        Library,
        LibraryGroup,
        License,
        ManifestationCheckoutStat,
        ManifestationRelationship,
        ManifestationRelationshipType,
        ManifestationReserveStat,
        MediumOfPerformance,
        Own,
        PatronRelationship,
        PatronRelationshipType,
        PictureFile,
        Produce,
        ProduceType,
        Realize,
        RealizeType,
        RemoveReason,
        SeriesStatement,
        SeriesHasManifestation,
        Shelf,
        Subject,
        SubjectHasClassification,
        SubjectHeadingType,
        UserCheckoutStat,
        UserGroup,
        UserReserveStat,
        WorkHasSubject
      ]
    end

    if defined?(EnjuBookmark)
      case user.try(:role).try(:name)
      when 'Administrator'
        can :manage, [
          Bookmark,
          BookmarkStat,
          BookmarkStatHasManifestation,
          Tag
        ]
      when 'Librarian'
        can [:read, :create, :update], BookmarkStat
        can :read, BookmarkStatHasManifestation
        can :manage, [
          Bookmark,
          Tag
        ]
      when 'User'
        can [:index, :create], Bookmark
        can :show, Bookmark do |bookmark|
          if bookmark.user == user
            true
          elsif user.share_bookmarks
            true
          else
            false
          end
        end
        can [:update, :destroy], Bookmark do |bookmark|
          bookmark.user == user
        end
        can :read, BookmarkStat
        can :read, Tag
      else
        can :read, BookmarkStat
        can :read, Tag
      end
    end

    #if defined?(EnjuMessage)
    if defined?(Message)
      case user.try(:role).try(:name)
      when 'Administrator'
        can :manage, Message
        can [:read, :update, :destroy], MessageRequest
        can [:read, :update], MessageTemplate
      when 'Librarian'
        can [:index, :create], Message
        can [:update], Message do |message|
          message.sender == user
        end
        can [:show, :destroy, :destroy_selected], Message do |message|
          message.receiver == user
        end
        can [:read, :update, :destroy], MessageRequest
        can :read, MessageTemplate
      when 'User'
        can [:read, :destroy, :destroy_selected], Message do |message|
          message.receiver == user
        end
        can [:index, :create], Message
        can :show, Message do |message|
          message.receiver == user
        end
      end
    end

    if defined?(EnjuEvent)
      case user.try(:role).try(:name)
      when 'Administrator'
        can [:read, :new, :create], EventCategory
        can [:edit, :update, :destroy], EventCategory do |event_category|
          !['unknown', 'closed'].include?(event_category.name)
        end
        can :manage, [
          Event,
          EventImportFile,
          Participate
        ]
        can :read, EventImportResult
      when 'Librarian'
        can [:read, :new, :create], EventCategory
        can [:edit, :update, :destroy], EventCategory do |event_category|
          !['unknown', 'closed'].include?(event_category.name)
        end
        can :manage, [
          Event,
          EventImportFile,
          Participate
        ]
        can :read, EventImportResult
      when 'User'
        can :read, [
          Event,
          EventCategory
        ]
      else
        can :read, [
          Event,
          EventCategory
        ]
      end
    end

    if defined?(EnjuNii)
      case user.try(:role).try(:name)
      when 'Administrator'
        can [:read, :update], NiiType
      else
        can :read, NiiType
      end
    end

    can :manage, :opac
  end
end
