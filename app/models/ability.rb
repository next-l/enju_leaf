class Ability
  include CanCan::Ability

  def initialize(user, ip_address)
    case user.try(:role).try(:name)
    when 'Administrator'
      can [:read, :create, :update], Bookstore
      can :destroy, Bookstore do |bookstore|
        bookstore.order_lists.empty?
      end
      can [:read, :create, :update], ClassificationType
      can :destroy, ClassificationType do |classification_type|
        classification_type.classifications.empty?
      end
      can [:read, :new, :create], EventCategory
      can [:edit, :update, :destroy], EventCategory do |event_category|
        !['unknown', 'closed'].include?(event_category.name)
      end
      can [:read, :create, :export_loan_lists, :get_loan_lists, :pickup, :pickup_item, :accept, :accept_item, :download_file], InterLibraryLoan
      can [:update, :destroy], InterLibraryLoan do |inter_library_loan|
        inter_library_loan.state == "pending" || inter_library_loan.state == "requested"
      end
      can [:read, :create, :update], Item
      can :destroy, Item do |item|
        item.deletable?
      end      
      can [:read, :create, :update], Library
      can :destroy, Library do |library|
        library.shelves.empty? and library.users.empty? and library.budgets.empty? and library.events.empty? and !library.web?
      end
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        manifestation.items.empty? and !manifestation.is_reserved?
      end
      can [:read, :create, :update], SeriesStatement
      can :destroy, SeriesStatement do |series_statement|
        series_statement.manifestations.empty?
      end
      can [:read, :create, :update], Patron
      can :destroy, Patron do |patron|
        if patron.user
          patron.user.checkouts.not_returned.empty?
        else
          true
        end
      end
      can [:read, :create, :update], Shelf
      can :destroy, Shelf do |shelf|
        shelf.items.empty?
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
        Answer,
        Barcode,
        Basket,
        Bookmark,
        BookmarkStat,
        BookmarkStatHasManifestation,
        Budget,
        CarrierTypeHasCheckoutType,
        CheckedItem,
        Checkin,
        Checkout,
        Checkoutlist,
        CheckoutStatHasManifestation,
        CheckoutStatHasUser,
        CheckoutType,
        Classification,
        Create,
        Donate,
        Event,
        Exemplify,
        EventImportFile,
        Family,
        ImportRequest,
        Inventory,
        InventoryFile,
        LendingPolicy,
        LibcheckDataFile,
        LibraryCheck,
        LibraryCheckShelf,
        LibraryReport,
        ItemHasUseRestriction,
        ManifestationCheckoutStat,
        ManifestationRelationship,
        ManifestationRelationshipType,
        ManifestationReserveStat,
        Order,
        OrderList,
        Own,
        Participate,
        PatronImportFile,
        PatronMerge,
        PatronMergeList,
        PatronRelationship,
        PatronRelationshipType,
        PictureFile,
        Produce,
        PurchaseRequest,
        Question,
        Realize,
        Reserve,
        ReserveStatHasManifestation,
        ReserveStatHasUser,
        ResourceImportFile,
        SearchEngine,
        SearchHistory,
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
        Tag,
        Term,
        UserCheckoutStat,
        UserGroupHasCheckoutType,
        UserHasRole,
        UserReserveStat,
        WorkHasSubject
      ]
      can [:read, :update], [
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
        MediumOfPerformance,
        PatronType,
        RequestStatusType,
        RequestType,
        Role,
        UseRestriction
      ]
      can :read, [
        EventImportResult,
        PatronImportResult,
        ResourceImportResult
      ]
    when 'Librarian'
      can [:index, :create], Bookmark
      can [:show, :update, :destroy], Bookmark do |bookmark|
        bookmark.user == user
      end
      can [:read, :create, :update], BookmarkStat
      can [:read, :new, :create], EventCategory
      can [:edit, :update, :destroy], EventCategory do |event_category|
        !['unknown', 'closed'].include?(event_category.name)
      end
      can [:read, :create, :export_loan_lists, :get_loan_lists, :pickup, :pickup_item, :accept, :accept_item, :download_file], InterLibraryLoan
      can [:update, :update, :destroy], InterLibraryLoan do |inter_library_loan|
        inter_library_loan.state == "pending" || inter_library_loan.state == "requested"
      end
      can [:read, :create, :update], Item
      can :destroy, Item do |item|
        item.checkouts.not_returned.empty?
      end
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        manifestation.items.empty? and !manifestation.is_reserved?
      end
      can [:read, :create, :update], SeriesStatement
      can :destroy, SeriesStatement do |series_statement|
        series_statement.manifestations.empty?
      end
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
      can [:index, :create, :update, :destroy, :show], Reserve
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
      can :manage, [
        Answer,
        Basket,
        Bookmark,
        Budget,
        CheckedItem,
        Checkin,
        Checkout,
        Checkoutlist,
        Create,
        Donate,
        Event,
        Exemplify,
        EventImportFile,
        Family,
        ImportRequest,
        Inventory,
        InventoryFile,
        LibcheckDataFile,
        LibraryCheck,
        LibraryCheckShelf,
        LibraryReport,
        ManifestationCheckoutStat,
        ManifestationRelationship,
        ManifestationReserveStat,
        Order,
        OrderList,
        Own,
        Participate,
        PatronImportFile,
        PatronMerge,
        PatronMergeList,
        PatronRelationship,
        PictureFile,
        Produce,
        PurchaseRequest,
        Question,
        Realize,
        Reserve,
        ResourceImportFile,
        SearchHistory,
        SeriesHasManifestation,
        SeriesStatementMerge,
        SeriesStatementMergeList,
        SubjectHasClassification,
        Subscribe,
        Subscription,
        SystemConfiguration,
        Tag,
        Term,
        WorkHasSubject
      ]
      can :read, [
        BookmarkStatHasManifestation,
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
        EventImportResult,
        Extent,
        Frequency,
        FormOfWork,
        ItemHasUseRestriction,
        Language,
        LendingPolicy,
        Library,
        LibraryGroup,
        License,
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
        Role,
        SearchEngine,
        Shelf,
        Subject,
        SubjectType,
        SubjectHeadingType,
        SubjectHeadingTypeHasSubject,
        UseRestriction,
        UserGroup,
        UserGroupHasCheckoutType
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
      can [:index, :create], Bookmark
      can [:show, :update, :destroy], Bookmark do |bookmark|
        bookmark.user == user
      end
      can [:create, :update, :show], Tag
      can [:index, :create], Checkout
      can [:show, :update, :destroy], Checkout do |checkout|
        checkout.user == user
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
      can [:index, :create], PurchaseRequest
      can [:show, :update, :destroy], PurchaseRequest do |purchase_request|
        purchase_request.user == user
      end
      can [:index, :create], Reserve
      can [:show, :update, :destroy], Reserve do |reserve|
        reserve.user == user && reserve.expired_at.end_of_day > Time.zone.now
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
        BookmarkStat,
        CarrierType,
        CirculationStatus,
        Classification,
        ClassificationType,
        ContentType,
        Country,
        Create,
        Event,
        EventCategory,
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
        Realize,
        SeriesStatement,
        SeriesHasManifestation,
        Shelf,
        Subject,
        SubjectHasClassification,
        SubjectHeadingType,
        UserCheckoutStat,
        UserReserveStat,
        UserGroup,
        WorkHasSubject
      ]
    else
      can :index, Answer
      can :show, Answer do |answer|
        answer.user == user or answer.shared
      end
      can :index, Checkout
      can :index, Patron
      can :show, Patron do |patron|
        patron.required_role_id == 1 #name == 'Guest'
      end
      can :index, Question
      can :show, Question do |question|
        question.user == user or question.shared
      end
      can :read, [
        BookmarkStat,
        CarrierType,
        CirculationStatus,
        Classification,
        ClassificationType,
        ContentType,
        Country,
        Create,
        Event,
        EventCategory,
        Exemplify,
        Extent,
        Frequency,
        FormOfWork,
        Item,
        Language,
        Library,
        LibraryGroup,
        License,
        Manifestation,
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
        Realize,
        SeriesStatement,
        SeriesHasManifestation,
        Shelf,
        Subject,
        SubjectHasClassification,
        SubjectHeadingType,
        Tag,
        UserCheckoutStat,
        UserGroup,
        UserReserveStat,
        WorkHasSubject
      ]
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
        can [:show, :destroy], Message do |message|
          message.receiver == user
        end
        can [:read, :update, :destroy], MessageRequest
        can :read, MessageTemplate
      when 'User'
        can [:read, :destroy], Message do |message|
          message.receiver == user
        end
        can :index, Message
        can :show, Message do |message|
          message.receiver == user
        end
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
  end
end
