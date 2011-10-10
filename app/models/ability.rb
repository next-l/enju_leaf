class Ability
  include CanCan::Ability

  def initialize(user, ip_address)
    case user.try(:role).try(:name)
    when 'Administrator'
      can [:read, :create, :update], Bookstore
      can :destroy, Bookstore do |bookstore|
        bookstore.order_lists.empty? and bookstore.items.empty?
      end
      can [:read, :create], EventCategory
      can [:update, :destroy], EventCategory do |event_category|
        !['unknown', 'closed'].include?(event_category.name)
      end
      can [:read, :create, :update], Item
      can :destroy, Item do |item|
        item.deletable?
      end
      can [:read, :create, :update], Library
      can :destroy, Library do |library|
        library.shelves.empty? and !library.web?
      end
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        manifestation.items.empty? and !manifestation.is_reserved? and !manifestation.periodical_master?
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
        Create,
        Donate,
        Event,
        Exemplify,
        EventImportFile,
        ImportRequest,
        InterLibraryLoan,
        ManifestationRelationship,
        ManifestationRelationshipType,
        Own,
        Participate,
        PatronImportFile,
        PatronMerge,
        PatronMergeList,
        PatronRelationship,
        PatronRelationshipType,
        PictureFile,
        Produce,
        Realize,
        ResourceImportFile,
        SearchEngine,
        SearchHistory,
        SeriesStatement,
        SeriesHasManifestation,
        SeriesStatementMerge,
        SeriesStatementMergeList,
        Subscribe,
        Subscription,
        UserHasRole
      ]
      can [:read, :update], [
        CarrierType,
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
        Role
      ]
      can :read, [
        EventImportResult,
        PatronImportResult,
        ResourceImportResult
      ]
    when 'Librarian'
      can [:read, :create, :update], Item
      can :destroy, Item do |item|
        item.checkouts.not_returned.empty?
      end
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        manifestation.items.empty? and !manifestation.is_reserved? and !manifestation.periodical_master?
      end
      can [:index, :create], Patron
      can :show, Patron do |patron|
        patron.required_role_id <= 3
      end
      can [:update, :destroy], Patron do |patron|
        !patron.user.try(:has_role?, 'Librarian') and patron.required_role_id <= 3
      end
      can :index, SearchHistory
      can [:show, :destroy], SearchHistory do |search_history|
        search_history.user == user
      end
      can [:read, :create, :update], User
      can :destroy, User do |u|
        u.checkouts.not_returned.empty? and u.role.name == 'User' and u != user
      end
      can :manage, [
        Create,
        Donate,
        Event,
        Exemplify,
        EventImportFile,
        ImportRequest,
        InterLibraryLoan,
        ManifestationRelationship,
        Own,
        Participate,
        PatronImportFile,
        PatronMerge,
        PatronMergeList,
        PatronRelationship,
        PictureFile,
        Produce,
        Realize,
        ResourceImportFile,
        SearchHistory,
        SeriesStatement,
        SeriesHasManifestation,
        SeriesStatementMerge,
        SeriesStatementMergeList,
        Subscribe,
        Subscription
      ]
      can :read, [
        Bookstore,
        CarrierType,
        ContentType,
        Country,
        EventCategory,
        EventImportResult,
        Extent,
        Frequency,
        FormOfWork,
        Language,
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
        ResourceImportResult,
        Role,
        SearchEngine,
        Shelf,
        UserGroup
      ]
    when 'User'
      can :index, Item
      can :show, Item do |item|
        item.required_role_id <= 2
      end
      can :read, Manifestation do |manifestation|
        manifestation.required_role_id <= 2
      end
      can :edit, Manifestation
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
      can :index, SearchHistory
      can [:show, :destroy], SearchHistory do |search_history|
        search_history.user == user
      end
      can :show, User
      can :update, User do |u|
        u == user
      end
      can :read, [
        CarrierType,
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
        MediumOfPerformance,
        Own,
        PatronRelationship,
        PatronRelationshipType,
        Produce,
        Realize,
        SeriesStatement,
        SeriesHasManifestation,
        Shelf,
        UserGroup
      ]
    else
      can :index, Patron
      can :show, Patron do |patron|
        patron.required_role_id == 1 #name == 'Guest'
      end
      can :read, [
        CarrierType,
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
        ManifestationRelationship,
        ManifestationRelationshipType,
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
        UserGroup
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
        can [:show, :update, :destroy], Bookmark do |bookmark|
          bookmark.user == user
        end
        can :read, BookmarkStat
        can :read, Tag
      else
        can :read, BookmarkStat
        can :read, Tag
      end
    end

    if defined?(EnjuMessage)
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

    if defined?(EnjuQuestion)
      case user.try(:role).try(:name)
      when 'Administrator'
        can :manage, Answer
        can :manage, Question
      when 'Librarian'
        can :manage, Answer
        can :manage, Question
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
        can [:index, :create], Question
        can [:update, :destroy], Question do |question|
          question.user == user
        end
        can :show, Question do |question|
          question.user == user or question.shared
        end
      else
        can :index, Answer
        can :show, Answer do |answer|
          answer.shared
        end
        can :index, Question
        can :show, Question do |question|
          question.shared
        end
      end
    end

    if defined?(EnjuSubject)
      case user.try(:role).try(:name)
      when 'Administrator'
        can [:read, :create, :update], ClassificationType
        can :destroy, ClassificationType do |classification_type|
          classification_type.classifications.empty?
        end
        can :manage, [
          Classification,
          Subject,
          SubjectHasClassification,
          SubjectHeadingType,
          SubjectHeadingTypeHasSubject,
          SubjectType
        ]
        can :manage, WorkHasSubject
      when 'Librarian'
        can :read, [
          Classification,
          ClassificationType,
          Subject,
          SubjectType,
          SubjectHeadingType,
          SubjectHeadingTypeHasSubject
        ]
        can :manage, [
          SubjectHasClassification,
          WorkHasSubject
        ]
      when 'User'
        can :read, [
          Classification,
          ClassificationType,
          Subject,
          SubjectHasClassification,
          SubjectHeadingType,
          WorkHasSubject
        ]
      else
        can :read, [
          Classification,
          ClassificationType,
          Subject,
          SubjectHasClassification,
          SubjectHeadingType,
          WorkHasSubject
        ]
      end
    end

    if defined?(EnjuCirculation)
      case user.try(:role).try(:name)
      when 'Administrator'
        can :manage, [
          Basket,
          CarrierTypeHasCheckoutType,
          CheckedItem,
          Checkin,
          Checkout,
          CheckoutStatHasManifestation,
          CheckoutStatHasUser,
          CheckoutType,
          ItemHasUseRestriction,
          LendingPolicy,
          ManifestationCheckoutStat,
          ManifestationReserveStat,
          Reserve,
          ReserveStatHasManifestation,
          ReserveStatHasUser,
          UserCheckoutStat,
          UserGroupHasCheckoutType,
          UserReserveStat
        ]
        can [:read, :update], [
          CirculationStatus,
          UseRestriction
        ]
      when 'Librarian'
        can :manage, [
          Basket,
          CheckedItem,
          Checkin,
          Checkout,
          ManifestationCheckoutStat,
          ManifestationReserveStat,
          Reserve
        ]
        can [:index, :create], Reserve
        can [:update, :destroy, :show], Reserve do |reserve|
          reserve.try(:user) == user
        end
        can [:read, :create, :update], UserCheckoutStat
        can [:read, :create, :update], UserReserveStat
        can :read, [
          CarrierTypeHasCheckoutType,
          CheckoutType,
          CheckoutStatHasManifestation,
          CheckoutStatHasUser,
          CirculationStatus,
          ItemHasUseRestriction,
          LendingPolicy,
          ReserveStatHasManifestation,
          ReserveStatHasUser,
          UseRestriction,
          UserGroupHasCheckoutType
        ]
      when 'User'
        can [:index, :create], Checkout
        can [:show, :update, :destroy], Checkout do |checkout|
          checkout.user == user
        end
        can [:index, :create], Reserve
        can [:show, :update, :destroy], Reserve do |reserve|
          reserve.user == user
        end
        can :read, [
          CirculationStatus,
          ManifestationCheckoutStat,
          ManifestationReserveStat,
          UserCheckoutStat,
          UserReserveStat,
        ]
      else
        can :index, Checkout
        can :read, [
          CirculationStatus,
          ManifestationCheckoutStat,
          ManifestationReserveStat,
          UserCheckoutStat,
          UserReserveStat
        ]
      end
    end

    if defined?(EnjuInventory)
      case user.try(:role).try(:name)
      when 'Administrator'
        can :manage, [
          Inventory,
          InventoryFile
        ]
      when 'Librarian'
        can :manage, [
          Inventory,
          InventoryFile
        ]
      when 'User'
      else
      end
    end

    if defined?(EnjuPurchaseRequest)
      case user.try(:role).try(:name)
      when 'Administrator'
        can :manage, [
          Order,
          OrderList,
          PurchaseRequest
        ]
      when 'Librarian'
        can :manage, [
          Order,
          OrderList,
          PurchaseRequest
        ]
      when 'User'
        can [:index, :create], PurchaseRequest
        can [:show, :update, :destroy], PurchaseRequest do |purchase_request|
          purchase_request.user == user
        end
      else
      end
    end
  end
end
