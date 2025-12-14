/// Task Library Data with Arabic titles, descriptions, and metadata
/// This maps task IDs (and common English titles) to full Arabic task details

class TaskLibrary {
  static final Map<String, TaskDetails> _tasksById = {
    // ========== RELAXATION & GROUNDING ==========
    'relax_deep_breathing': TaskDetails(
      id: 'relax_deep_breathing',
      title: 'تمرين التنفس العميق',
      description: 'خصّص ٥–١٠ دقائق مرة إلى ثلاث مرات في اليوم للتركيز على التنفس البطيء: شهيق عميق من الأنف لمدة ٤ ثوانٍ، حبس النفس لثانيتين، ثم زفير بطيء من الفم لمدة ٦ ثوانٍ، مع ملاحظة استرخاء الجسد.',
      category: 'استرخاء',
      difficulty: 'سهل',
    ),
    'relax_progressive_muscle': TaskDetails(
      id: 'relax_progressive_muscle',
      title: 'استرخاء العضلات التدريجي',
      description: 'مرّة واحدة على الأقل يومياً: اختر وقتاً هادئاً، وابدأ من القدمين حتى الوجه. شدّ كل مجموعة عضلية لمدة ٥ ثوانٍ ثم أرخها تماماً لمدة ١٠ ثوانٍ، مع ملاحظة الفرق بين التوتر والاسترخاء.',
      category: 'استرخاء',
      difficulty: 'سهل',
    ),
    'grounding_54321': TaskDetails(
      id: 'grounding_54321',
      title: 'تمرين التأريض 5-4-3-2-1',
      description: 'عند ارتفاع القلق، طبّق تمرين التأريض: عدّد ٥ أشياء تراها، ٤ أشياء تلمسها، ٣ أشياء تسمعها، شيئين تشمهما، وشيئاً واحداً تتذوقه، مع التركيز على الحواس لإعادة الحضور للحظة الحالية.',
      category: 'استرخاء',
      difficulty: 'سهل',
    ),
    'relax_safe_place_visualization': TaskDetails(
      id: 'relax_safe_place_visualization',
      title: 'تخيّل المكان الآمن',
      description: 'اختر مكاناً تشعر فيه بالأمان (حقيقي أو متخيّل)، وأغلق عينيك لدقائق قليلة يومياً وتخيّل تفاصيله: الأصوات، الألوان، الروائح، وركّز على الإحساس بالراحة والطمأنينة في هذا المكان.',
      category: 'استرخاء',
      difficulty: 'سهل',
    ),

    // ========== THOUGHT RECORD ==========
    'thought_record_basic': TaskDetails(
      id: 'thought_record_basic',
      title: 'سجل الأفكار التلقائية',
      description: 'على الأقل مرّتين في الأسبوع: عندما تشعر بانزعاج عاطفي قوي، اكتب الموقف، والفكرة التلقائية، والمشاعر مع شدتها من ٠–١٠، ثم اكتب أدلة مع وضد الفكرة، وأخيراً فكرة بديلة أكثر توازناً.',
      category: 'معرفي',
      difficulty: 'متوسط',
    ),
    'distortion_spotting_log': TaskDetails(
      id: 'distortion_spotting_log',
      title: 'مذكّرة تشخيص التشوّهات المعرفية',
      description: 'خلال الأسبوع، في كل مرة تلاحظ فيها فكرة سلبية قوية، دوّن الفكرة، والموقف، والمشاعر، ثم اختر نوع التشوّه المعرفي الأقرب، واكتب كيف يمكن أن تبدو الفكرة إذا كانت أكثر توازناً.',
      category: 'معرفي',
      difficulty: 'متوسط',
    ),
    'gratitude_journal': TaskDetails(
      id: 'gratitude_journal',
      title: 'مذكّرة الامتنان اليومية',
      description: 'كل مساء قبل النوم، اكتب ٣ أشياء تشعر بالامتنان لوجودها في يومك، ولو كانت بسيطة جداً، ودوّن سبب أهميتها لك وما الشعور الذي تولّده لديك.',
      category: 'تأمل',
      difficulty: 'سهل',
    ),
    'evidence_log_self_worth': TaskDetails(
      id: 'evidence_log_self_worth',
      title: 'سجل الأدلة على القيمة الذاتية',
      description: 'إذا ظهرت أفكار مثل "أنا فاشل" أو "لا أساوي شيئاً"، اكتب الفكرة، ثم سجّل يومياً ٣ مواقف صغيرة تُظهر كفاءة أو لطفاً أو التزاماً من جانبك، حتى لو بدت بسيطة.',
      category: 'معرفي',
      difficulty: 'متوسط',
    ),
    'emotion_vs_fact_journal': TaskDetails(
      id: 'emotion_vs_fact_journal',
      title: 'تمييز المشاعر عن الحقائق',
      description: 'عند شعور قوي (مثل خوف أو حزن)، اكتب: ماذا أشعر الآن؟ ماذا أستنتج من هذا الشعور؟ ثم اسأل: ما هي الحقائق المؤكدة؟ واكتب جملة تفصل بين "أشعر أن..." و"الواقع هو أن...".',
      category: 'معرفي',
      difficulty: 'متوسط',
    ),
    'should_to_preference_practice': TaskDetails(
      id: 'should_to_preference_practice',
      title: 'استبدال "يجب" بـ"أفضل"',
      description: 'لمدة أسبوع، راقب العبارات التي تبدأ بـ"لازم" أو "يجب" عن نفسك أو الآخرين، واكتب كل عبارة ثم أعد صياغتها إلى تفضيل واقعي مثل "أفضل أن" أو "أرغب في"، ولاحظ الفرق في شعورك.',
      category: 'معرفي',
      difficulty: 'سهل',
    ),

    // ========== BEHAVIORAL EXPERIMENT ==========
    'behavioral_experiment_social': TaskDetails(
      id: 'behavioral_experiment_social',
      title: 'تجربة سلوكية اجتماعية بسيطة',
      description: 'اختر موقفاً اجتماعياً بسيطاً تتجنبه عادةً (مثل إلقاء السلام أو طرح سؤال قصير)، دوّن توقعك لما سيحدث قبل الموقف، نفّذ التجربة، ثم اكتب ما حدث فعلاً وما الذي تعلمته.',
      category: 'سلوكي',
      difficulty: 'متوسط',
    ),
    'fear_ladder_step': TaskDetails(
      id: 'fear_ladder_step',
      title: 'خطوة من سلّم المواجهة',
      description: 'اكتب سلّم مواجهة يبدأ من موقف يثير قلقاً بسيطاً حتى موقف يقلقك بشدة. هذا الأسبوع، نفّذ خطوة واحدة فقط من الدرجات السهلة، وقيّم شدة القلق قبل وبعد (٠–١٠) وما تعلّمته.',
      category: 'سلوكي',
      difficulty: 'متوسط',
    ),
    'experiment_failure_prediction': TaskDetails(
      id: 'experiment_failure_prediction',
      title: 'اختبار توقع الفشل',
      description: 'اختر مهمة صغيرة تميل لتأجيلها خوفاً من الفشل (مثل إرسال رسالة، أو إكمال جزء من مشروع)، اكتب ما تتوقع حدوثه إذا جرّبت، نفّذ المهمة، ثم قارن بين التوقع والواقع وما تعلّمته.',
      category: 'سلوكي',
      difficulty: 'متوسط',
    ),
    'anger_delay_experiment': TaskDetails(
      id: 'anger_delay_experiment',
      title: 'تجربة تأجيل ردّة الفعل في الغضب',
      description: 'في موقف يغضبك هذا الأسبوع، جرّب تأجيل ردّة الفعل ٣–٥ دقائق: غادر المكان إن أمكن، طبّق تنفساً عميقاً، واكتب ما تشعر به. بعد أن تهدأ، قرر كيف تود الرد.',
      category: 'سلوكي',
      difficulty: 'متوسط',
    ),

    // ========== ACTIVITY SCHEDULING ==========
    'pleasant_activity_scheduling': TaskDetails(
      id: 'pleasant_activity_scheduling',
      title: 'جدولة أنشطة ممتعة',
      description: 'اكتب قائمة بـ٥ أنشطة بسيطة تمنحك شعوراً بالمتعة (مثل المشي، الحديث مع صديق، هواية خفيفة)، واختر ٣ منها لتطبيقها خلال هذا الأسبوع، ودوّن مزاجك قبل وبعد كل نشاط.',
      category: 'جدولة',
      difficulty: 'سهل',
    ),
    'mastery_activity_scheduling': TaskDetails(
      id: 'mastery_activity_scheduling',
      title: 'أنشطة تعزز الإحساس بالإنجاز',
      description: 'اختر ٣ مهام صغيرة تعطيك شعوراً بالإنجاز (مثل ترتيب جزء من الغرفة، إنهاء جزء من واجب، مراجعة ملاحظات)، وجدولها خلال الأسبوع، وقيّم شعور الإنجاز من ٠–١٠ بعد كل مهمة.',
      category: 'جدولة',
      difficulty: 'متوسط',
    ),
    'physical_exercise_routine': TaskDetails(
      id: 'physical_exercise_routine',
      title: 'روتين نشاط بدني بسيط',
      description: 'اختر نوعاً مفضلاً من الحركة الخفيفة (مثل المشي أو التمارين المنزلية)، وحدّد ٣ أيام هذا الأسبوع لممارسة ٢٠–٣٠ دقيقة في كل مرة، ودوّن مستوى الطاقة والمزاج قبل وبعد كل جلسة.',
      category: 'نشاط',
      difficulty: 'متوسط',
    ),
    'sleep_hygiene_plan': TaskDetails(
      id: 'sleep_hygiene_plan',
      title: 'خطة عادات نوم صحّية',
      description: 'لمدة أسبوع، التزم بوقت ثابت تقريباً للنوم والاستيقاظ، وتجنّب الشاشات والأكل الثقيل قبل النوم بساعة، وسجّل عدد ساعات النوم وجودته (من ٠–١٠) كل ليلة.',
      category: 'نوم',
      difficulty: 'متوسط',
    ),

    // ========== SELF-COMPASSION ==========
    'daily_strengths_log': TaskDetails(
      id: 'daily_strengths_log',
      title: 'سجل نقاط القوة والنجاحات الصغيرة',
      description: 'كل يوم، دوّن على الأقل أمرين فعلتهما جيداً أو أظهرت فيهما صبراً أو التزاماً، ولو كان شيئاً بسيطاً جداً، مع جملة قصيرة عمّا يكشفه ذلك عنك كشخص.',
      category: 'تعاطف',
      difficulty: 'سهل',
    ),
    'self_compassion_letter': TaskDetails(
      id: 'self_compassion_letter',
      title: 'رسالة تعاطف مع الذات',
      description: 'اكتب رسالة لنفسك كما لو كنت تكتب لصديق مقرّب يمر بنفس مشكلتك: عبّر فيها عن التفهّم، واعترافك بصعوبة ما يمر به، واذكر نقاط قوّة حقيقية لديه.',
      category: 'تعاطف',
      difficulty: 'صعب',
    ),
  };

  /// English title to Arabic mapping for common tasks
  static final Map<String, TaskDetails> _tasksByEnglishTitle = {
    'challenge and replace thoughts': TaskDetails(
      id: 'thought_record_basic',
      title: 'تحدي واستبدال الأفكار',
      description: 'عندما تلاحظ فكرة سلبية، اكتبها ثم تحداها بالأسئلة: ما الدليل؟ هل هناك تفسير آخر؟ ثم اكتب فكرة بديلة أكثر توازناً.',
      category: 'معرفي',
      difficulty: 'متوسط',
    ),
    'daily reflection': TaskDetails(
      id: 'gratitude_journal',
      title: 'التأمل اليومي',
      description: 'خصص وقتاً كل يوم للتأمل في أحداث اليوم ومشاعرك. اكتب ما تعلمته وما أنت ممتن له.',
      category: 'تأمل',
      difficulty: 'سهل',
    ),
    'identify negative thoughts': TaskDetails(
      id: 'distortion_spotting_log',
      title: 'تحديد الأفكار السلبية',
      description: 'راقب أفكارك خلال اليوم. عندما تلاحظ فكرة سلبية، دوّنها مع الموقف والمشاعر المصاحبة لها.',
      category: 'وعي',
      difficulty: 'متوسط',
    ),
    'breathing exercise': TaskDetails(
      id: 'relax_deep_breathing',
      title: 'تمرين التنفس العميق',
      description: 'خصّص ٥–١٠ دقائق للتركيز على التنفس البطيء: شهيق عميق من الأنف، حبس النفس، ثم زفير بطيء من الفم.',
      category: 'استرخاء',
      difficulty: 'سهل',
    ),
    'grounding exercise': TaskDetails(
      id: 'grounding_54321',
      title: 'تمرين التأريض',
      description: 'استخدم حواسك للعودة للحظة الحالية: ٥ أشياء تراها، ٤ تلمسها، ٣ تسمعها، ٢ تشمها، ١ تتذوقه.',
      category: 'استرخاء',
      difficulty: 'سهل',
    ),
  };

  /// Get task details by ID or English title
  static TaskDetails? getTaskDetails(Map<String, dynamic> task) {
    // First try by task_id or id
    final String? taskId = (task['task_id'] ?? task['id'])?.toString();
    if (taskId != null && _tasksById.containsKey(taskId)) {
      return _tasksById[taskId];
    }

    // Get the title from task
    final String? title = (task['title'] ?? task['task'] ?? task['task_name'])?.toString();
    if (title == null) return null;
    
    final lowerTitle = title.toLowerCase().trim();
    final trimmedTitle = title.trim();

    // Try by English title (lowercase)
    if (_tasksByEnglishTitle.containsKey(lowerTitle)) {
      return _tasksByEnglishTitle[lowerTitle];
    }

    // Try to find by Arabic title in both maps
    for (var entry in _tasksById.values) {
      if (entry.title == trimmedTitle || entry.title.contains(trimmedTitle) || trimmedTitle.contains(entry.title)) {
        return entry;
      }
    }
    
    for (var entry in _tasksByEnglishTitle.values) {
      if (entry.title == trimmedTitle || entry.title.contains(trimmedTitle) || trimmedTitle.contains(entry.title)) {
        return entry;
      }
    }

    return null;
  }

  /// Get Arabic title for a task (falls back to original title if not found)
  static String getArabicTitle(Map<String, dynamic> task) {
    final details = getTaskDetails(task);
    if (details != null) return details.title;
    return (task['title'] ?? task['task'] ?? task['task_name'] ?? 'مهمة').toString();
  }

  /// Get Arabic description for a task
  static String? getArabicDescription(Map<String, dynamic> task) {
    final details = getTaskDetails(task);
    return details?.description ?? task['description']?.toString();
  }

  /// Get difficulty in Arabic
  static String getArabicDifficulty(Map<String, dynamic> task) {
    final details = getTaskDetails(task);
    if (details != null) return details.difficulty;
    
    final difficulty = (task['difficulty'] ?? '').toString().toLowerCase();
    switch (difficulty) {
      case 'low':
      case 'easy':
        return 'سهل';
      case 'high':
      case 'hard':
        return 'صعب';
      case 'medium':
      default:
        return 'متوسط';
    }
  }

  /// Get category in Arabic  
  static String getArabicCategory(Map<String, dynamic> task) {
    final details = getTaskDetails(task);
    if (details != null) return details.category;
    return 'مهمة';
  }
}

class TaskDetails {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;

  const TaskDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
  });
}
