const messages = <String, Map<String, String>>{
  "unit_dona": {"uz": "dona", "ru": "шт.", "en": "pcs"},
  "unit_kg": {"uz": "kg", "ru": "кг", "en": "kg"},
  "unit_gramm": {"uz": "gramm", "ru": "г", "en": "g"},
  "unit_litr": {"uz": "litr", "ru": "л", "en": "l"},
  "unit_ml": {"uz": "ml", "ru": "мл", "en": "ml"},
  "unit_metr": {"uz": "metr", "ru": "м", "en": "m"},
  "unit_m²": {"uz": "m²", "ru": "м²", "en": "m²"},
  "unit_m³": {"uz": "m³", "ru": "м³", "en": "m³"},
  "unit_quti": {"uz": "quti", "ru": "коробка", "en": "box"},
  "unit_paket": {"uz": "paket", "ru": "пакет", "en": "bag"},
  "unit_pachka": {"uz": "pachka", "ru": "пачка", "en": "pack"},
  "unit_butilka": {"uz": "butilka", "ru": "бутылка", "en": "bottle"},
  "requestTimeout": {
    "uz": "Server javobi belgilangan vaqtda kelmadi. Qayta urinib ko‘ring.",
    "ru": "Время ожидания ответа истекло. Повторите попытку.",
    "en": "The server did not respond in time. Please try again."
  },
  "certificateError": {
    "uz": "Serverning xavfsiz ulanish sertifikatini tekshirib bo‘lmadi.",
    "ru": "Не удалось проверить сертификат безопасного соединения сервера.",
    "en": "The server connection certificate could not be verified."
  },
  "requestCancelled": {
    "uz": "So‘rov bekor qilindi.",
    "ru": "Запрос отменён.",
    "en": "The request was cancelled."
  },
  "requestFailed": {
    "uz": "So‘rovni bajarib bo‘lmadi. Qayta urinib ko‘ring.",
    "ru": "Не удалось выполнить запрос. Повторите попытку.",
    "en": "The request could not be completed. Please try again."
  },
  "responseInvalid": {
    "uz": "Serverdan kutilmagan javob olindi.",
    "ru": "Сервер вернул неожиданный ответ.",
    "en": "The server returned an unexpected response."
  },
  "quantity_increase": {
    "uz": "Miqdorni oshirish",
    "ru": "Увеличить количество",
    "en": "Increase quantity"
  },
  "quantity_decrease": {
    "uz": "Miqdorni kamaytirish",
    "ru": "Уменьшить количество",
    "en": "Decrease quantity"
  },
  "m0": {
    "uz": " Mahsulotlarni keyinroq yangilang.",
    "ru": " Обновите товары позже.",
    "en": " Refresh products later."
  },
  "m1": {
    "uz": "\"{0}\" bo'yicha natija yo'q",
    "ru": "Нет результатов для «{0}»",
    "en": "No results for “{0}”"
  },
  "m2": {"uz": "-{0} so'm", "ru": "−{0} сум", "en": "−{0} UZS"},
  "m3": {
    "uz": "1 dan 36 oygacha. 12 oy = 1 yil.",
    "ru": "От 1 до 36 месяцев. 12 месяцев = 1 год.",
    "en": "1–36 months. 12 months = 1 year."
  },
  "m4": {
    "uz": "1–36 oralig‘ida oy kiriting.",
    "ru": "Введите от 1 до 36 месяцев.",
    "en": "Enter 1–36 months."
  },
  "m5": {"uz": "30 kun", "ru": "30 дней", "en": "30 days"},
  "m6": {"uz": "7 kun", "ru": "7 дней", "en": "7 days"},
  "m7": {"uz": "Admin", "ru": "Администратор", "en": "Admin"},
  "m8": {
    "uz": "Admin Panel",
    "ru": "Панель администратора",
    "en": "Admin panel"
  },
  "m9": {
    "uz": "Admin Panelga xush kelibsiz",
    "ru": "Добро пожаловать в панель администратора",
    "en": "Welcome to the admin panel"
  },
  "m10": {
    "uz": "Admin panel",
    "ru": "Панель администратора",
    "en": "Admin panel"
  },
  "m11": {
    "uz": "Admin tomonidan berilgan kodni kiriting va parolingizni o‘rnating",
    "ru": "Введите код администратора и установите пароль",
    "en": "Enter the code from your administrator and set a password"
  },
  "m12": {
    "uz": "Admindan chiqmoqchimisiz?",
    "ru": "Выйти из панели администратора?",
    "en": "Leave the admin panel?"
  },
  "m13": {"uz": "Administrator", "ru": "Администратор", "en": "Administrator"},
  "m14": {"uz": "Akkaunt", "ru": "Аккаунт", "en": "Account"},
  "m15": {
    "uz": "Akkaunt holati",
    "ru": "Статус аккаунта",
    "en": "Account status"
  },
  "m16": {
    "uz": "Akkaunt o‘zgargan.",
    "ru": "Аккаунт изменён.",
    "en": "Account changed."
  },
  "m17": {
    "uz": "Akkaunt o‘zgargan. Eski sessiya bilan ishlash mumkin emas.",
    "ru": "Аккаунт изменён. Предыдущая сессия недоступна.",
    "en": "Account changed. The previous session is no longer available."
  },
  "m18": {
    "uz": "Akkaunt tekshirilmoqda...",
    "ru": "Проверка аккаунта…",
    "en": "Checking account…"
  },
  "m19": {
    "uz": "Akkauntdan chiqasizmi? Qayta kirish uchun internet kerak bo‘ladi.",
    "ru": "Выйти из аккаунта? Для повторного входа нужен интернет.",
    "en": "Sign out? You will need internet to sign in again."
  },
  "m20": {
    "uz": "Akkauntdan chiqish",
    "ru": "Выход из аккаунта",
    "en": "Sign out"
  },
  "m21": {
    "uz": "Akkauntga kirish cheklangan.",
    "ru": "Доступ к аккаунту ограничен.",
    "en": "Account access is restricted."
  },
  "m22": {
    "uz": "Akkauntga qayta kiring.",
    "ru": "Войдите в аккаунт снова.",
    "en": "Sign in again."
  },
  "m23": {
    "uz": "Aktivatsiya amalga oshmadi.",
    "ru": "Не удалось активировать аккаунт.",
    "en": "Account activation failed."
  },
  "m24": {
    "uz": "Aktivatsiya kodi",
    "ru": "Код активации",
    "en": "Activation code"
  },
  "m25": {
    "uz": "Aktivatsiya kodini kiriting",
    "ru": "Введите код активации",
    "en": "Enter the activation code"
  },
  "m26": {
    "uz": "Aktivatsiya qilinmoqda...",
    "ru": "Активация…",
    "en": "Activating…"
  },
  "m27": {
    "uz": "Aktivatsiya xatosi: {0}",
    "ru": "Ошибка активации: {0}",
    "en": "Activation error: {0}"
  },
  "m28": {
    "uz": "Amal sababini kiriting.",
    "ru": "Укажите причину действия.",
    "en": "Enter a reason for this action."
  },
  "m29": {
    "uz":
        "Amal tasdiqlanmadi. Qayta uzaytirishdan oldin ro‘yxatni yangilab muddatni tekshiring.",
    "ru":
        "Действие не подтверждено. Обновите список и проверьте срок перед повторным продлением.",
    "en":
        "Action not confirmed. Refresh the list and check the expiry before extending again."
  },
  "m30": {
    "uz": "Aniq summani kiritish",
    "ru": "Внести точную сумму",
    "en": "Enter exact amount"
  },
  "m31": {
    "uz": "Ariza yuborildi. Administrator tasdiqlashini kuting.",
    "ru": "Заявка отправлена. Ожидайте подтверждения администратора.",
    "en": "Request sent. Awaiting administrator approval."
  },
  "m32": {
    "uz": "Ariza yuborilmadi. Internetni tekshirib qayta urining.",
    "ru":
        "Не удалось отправить заявку. Проверьте интернет и повторите попытку.",
    "en": "Request not sent. Check your connection and try again."
  },
  "m33": {
    "uz": "Ariza yuborish",
    "ru": "Отправить заявку",
    "en": "Send request"
  },
  "m34": {"uz": "Arxivlash", "ru": "Архивировать", "en": "Archive"},
  "m35": {
    "uz": "Asosiy ma'lumotlar",
    "ru": "Основные сведения",
    "en": "Basic information"
  },
  "m36": {
    "uz": "Asosiy sahifaga qaytish",
    "ru": "На главную",
    "en": "Back to home"
  },
  "m37": {"uz": "Audit", "ru": "Аудит", "en": "Audit"},
  "m38": {"uz": "Audit log", "ru": "Журнал аудита", "en": "Audit log"},
  "m39": {"uz": "Audit yozuvi", "ru": "Запись аудита", "en": "Audit entry"},
  "m40": {"uz": "Authorization", "ru": "Авторизация", "en": "Authorization"},
  "m41": {
    "uz": "Avtomatik generatsiya",
    "ru": "Сгенерировать автоматически",
    "en": "Generate automatically"
  },
  "m42": {
    "uz":
        "Avval tasdiqlanmagan sotuvlarni sinxronlang yoki ziddiyatlarni hal qiling. Keyin mahsulotni o‘zgartiring.",
    "ru":
        "Сначала синхронизируйте неподтверждённые продажи или разрешите конфликты. Затем измените товар.",
    "en": "Sync unconfirmed sales or resolve conflicts before editing products."
  },
  "m43": {"uz": "Ayirish", "ru": "Вычесть", "en": "Subtract"},
  "m44": {"uz": "Ayrildi", "ru": "Вычтено", "en": "Subtracted"},
  "m45": {"uz": "Backend/API", "ru": "Backend/API", "en": "Backend/API"},
  "m46": {
    "uz": "Backup monitoring",
    "ru": "Мониторинг резервных копий",
    "en": "Backup monitoring"
  },
  "m47": {
    "uz": "Bank o‘tkazmasi",
    "ru": "Банковский перевод",
    "en": "Bank transfer"
  },
  "m48": {"uz": "Barcha holatlar", "ru": "Все статусы", "en": "All statuses"},
  "m49": {"uz": "Barcha muddatlar", "ru": "Все сроки", "en": "All due dates"},
  "m50": {"uz": "Barcha qarzlar", "ru": "Все долги", "en": "All debts"},
  "m51": {
    "uz": "Barcha userlar ro'yxati",
    "ru": "Список пользователей",
    "en": "All users"
  },
  "m52": {
    "uz": "Barcha {0} ta mahsulot o'chiriladi",
    "ru": "Будут удалены все товары: {0}",
    "en": "All {0} products will be removed"
  },
  "m53": {"uz": "Barchasi", "ru": "Все", "en": "All"},
  "m54": {"uz": "Barchasini tozalash", "ru": "Очистить всё", "en": "Clear all"},
  "m55": {"uz": "Bekor", "ru": "Отмена", "en": "Cancel"},
  "m56": {"uz": "Bekor qilingan", "ru": "Отменено", "en": "Cancelled"},
  "m57": {"uz": "Bekor qilish", "ru": "Отменить", "en": "Cancel"},
  "m58": {
    "uz": "Bir martalik kod:",
    "ru": "Одноразовый код:",
    "en": "One-time code:"
  },
  "m59": {
    "uz": "Bir operatsiya ID si bilan boshqa sotuv saqlanmoqda.",
    "ru": "С этим ID операции сохраняется другая продажа.",
    "en": "Another sale is being saved with this operation ID."
  },
  "m60": {
    "uz":
        "Birinchi kirish uchun internet kerak. Offline ishlash oldindan tasdiqlangan akkaunt uchun mavjud.",
    "ru":
        "Для первого входа нужен интернет. Офлайн-доступ доступен для ранее подтверждённого аккаунта.",
    "en":
        "Internet is required for the first sign-in. Offline access is available for a previously verified account."
  },
  "m61": {
    "uz": "Birinchi mahsulotingizni qo'shing va\nsotuvni boshlang",
    "ru": "Добавьте первый товар и начните продажи",
    "en": "Add your first product to start selling"
  },
  "m62": {
    "uz": "Birlikni tanlang",
    "ru": "Выберите единицу измерения",
    "en": "Select a unit"
  },
  "m63": {"uz": "Bloklangan", "ru": "Заблокирован", "en": "Blocked"},
  "m64": {
    "uz": "Bloklangan / aktivatsiya kutilmoqda",
    "ru": "Заблокирован / ожидает активации",
    "en": "Blocked / awaiting activation"
  },
  "m65": {
    "uz": "Bloklangan userlar",
    "ru": "Заблокированные пользователи",
    "en": "Blocked users"
  },
  "m66": {"uz": "Bloklash", "ru": "Заблокировать", "en": "Block"},
  "m67": {
    "uz": "Bloklash sababi",
    "ru": "Причина блокировки",
    "en": "Reason for blocking"
  },
  "m68": {
    "uz": "Bloklash sababini kiriting",
    "ru": "Укажите причину блокировки",
    "en": "Enter a reason for blocking"
  },
  "m69": {
    "uz": "Bog‘langan userlar",
    "ru": "Связанные пользователи",
    "en": "Linked users"
  },
  "m70": {"uz": "Bosh sahifa", "ru": "Главная", "en": "Home"},
  "m71": {
    "uz": "Boshlang'ich qoldiq",
    "ru": "Начальный остаток",
    "en": "Opening stock"
  },
  "m72": {
    "uz":
        "Boshlang'ich qoldiq kiritish ixtiyoriy. Keyinchalik ombor harakatlaridan o'zgartirishingiz mumkin.",
    "ru":
        "Начальный остаток необязателен. Позже его можно изменить через складские операции.",
    "en":
        "Opening stock is optional. You can adjust it later using inventory movements."
  },
  "m73": {"uz": "Boshlang‘ich: {0}", "ru": "Начало: {0}", "en": "Starts: {0}"},
  "m74": {"uz": "Boshlanish sanasi", "ru": "Дата начала", "en": "Start date"},
  "m75": {"uz": "Boshqa kamera", "ru": "Другая камера", "en": "Switch camera"},
  "m76": {
    "uz": "Boshqaruv paneli",
    "ru": "Панель управления",
    "en": "Dashboard"
  },
  "m77": {"uz": "Bosing", "ru": "Нажмите", "en": "Tap"},
  "m78": {
    "uz": "Bo‘lim ma’lumotlari yuklanmadi: {0}",
    "ru": "Не удалось загрузить раздел: {0}",
    "en": "Could not load this section: {0}"
  },
  "m79": {
    "uz":
        "Bu amal uchun ruxsat yo‘q. Hisobingiz va do‘kon huquqlarini tekshiring.",
    "ru":
        "Нет разрешения на это действие. Проверьте права аккаунта и магазина.",
    "en":
        "You do not have permission for this action. Check your account and store permissions."
  },
  "m80": {
    "uz": "Bu birinchi kirish. Yangi parol o'rnating.",
    "ru": "Первый вход. Установите новый пароль.",
    "en": "First sign-in. Set a new password."
  },
  "m81": {
    "uz": "Bu davrda sotuvlar yo'q",
    "ru": "За этот период продаж нет",
    "en": "No sales for this period"
  },
  "m82": {"uz": "Bu oy", "ru": "Этот месяц", "en": "This month"},
  "m83": {
    "uz": "Bu shtrix-kod yoki SKU bo‘yicha mahsulot topilmadi.",
    "ru": "Товар с таким штрихкодом или SKU не найден.",
    "en": "No product matches this barcode or SKU."
  },
  "m84": {
    "uz":
        "Bu tugma kartadan pul yechmaydi. To‘lov rekvizitlarini administrator bilan kelishing. To‘lovdan keyin izoh yoki tranzaksiya raqamini kiriting.",
    "ru":
        "Эта кнопка не списывает деньги с карты. Уточните реквизиты у администратора. После оплаты укажите комментарий или номер транзакции.",
    "en":
        "This button does not charge your card. Ask your administrator for payment details. After paying, enter a note or transaction number."
  },
  "m85": {"uz": "Bugun", "ru": "Сегодня", "en": "Today"},
  "m86": {
    "uz": "Bugun to‘lanadi",
    "ru": "Срок оплаты сегодня",
    "en": "Due today"
  },
  "m89": {"uz": "Chegirma", "ru": "Скидка", "en": "Discount"},
  "m90": {
    "uz": "Chegirma foizi",
    "ru": "Скидка, %",
    "en": "Discount percentage"
  },
  "m91": {
    "uz": "Chegirma noto‘g‘ri yoki jami summadan katta.",
    "ru": "Скидка некорректна или превышает итог.",
    "en": "The discount is invalid or exceeds the total."
  },
  "m92": {
    "uz": "Chegirma yoki umumiy summa noto‘g‘ri.",
    "ru": "Скидка или итог некорректны.",
    "en": "Invalid discount or total."
  },
  "m93": {"uz": "Chegirma:", "ru": "Скидка:", "en": "Discount:"},
  "m94": {
    "uz": "Chegirmani tekshiring.",
    "ru": "Проверьте скидку.",
    "en": "Check the discount."
  },
  "m95": {"uz": "Chek", "ru": "Чек", "en": "Receipt"},
  "m96": {"uz": "Chek №:", "ru": "Чек №:", "en": "Receipt no.:"},
  "m97": {"uz": "Chiqish", "ru": "Выйти", "en": "Sign out"},
  "m98": {"uz": "Chiroq", "ru": "Фонарик", "en": "Flashlight"},
  "m99": {"uz": "Chop qilish", "ru": "Печать", "en": "Print"},
  "m100": {
    "uz": "Chop qilish tez orada...",
    "ru": "Печать пока недоступна",
    "en": "Printing is not yet available"
  },
  "m101": {"uz": "Connection", "ru": "Подключение", "en": "Connection"},
  "m102": {
    "uz": "DOKON BOSHQARUV",
    "ru": "DOKON BOSHQARUV",
    "en": "DOKON BOSHQARUV"
  },
  "m103": {"uz": "Daftar", "ru": "Долги", "en": "Debts"},
  "m104": {
    "uz": "Daftarni yuklab bo‘lmadi. Internetni tekshiring.",
    "ru": "Не удалось загрузить долги. Проверьте интернет.",
    "en": "Could not load debts. Check your connection."
  },
  "m105": {"uz": "Dashboard", "ru": "Панель управления", "en": "Dashboard"},
  "m106": {
    "uz": "Dashboardni yuklab bo‘lmadi",
    "ru": "Не удалось загрузить панель",
    "en": "Could not load the dashboard"
  },
  "m107": {"uz": "Davom etish", "ru": "Продолжить", "en": "Continue"},
  "m108": {
    "uz": "Diqqat! {0} kam qoldi.",
    "ru": "Внимание! Мало товара: {0}.",
    "en": "Warning! Low stock: {0}."
  },
  "m109": {"uz": "Do'kon", "ru": "Магазин", "en": "Store"},
  "m110": {
    "uz": "Do'kon mavjud emas",
    "ru": "Магазин отсутствует",
    "en": "No store assigned"
  },
  "m111": {"uz": "Do'kon nomi", "ru": "Название магазина", "en": "Store name"},
  "m112": {"uz": "Do'konlar", "ru": "Магазины", "en": "Stores"},
  "m113": {"uz": "e-dukon", "ru": "e-dukon", "en": "e-dukon"},
  "m114": {"uz": "Do‘kon", "ru": "Магазин", "en": "Store"},
  "m115": {
    "uz": "Do‘kon ID si topilmadi. Ro‘yxatni yangilang.",
    "ru": "ID магазина не найден. Обновите список.",
    "en": "Store ID not found. Refresh the list."
  },
  "m116": {
    "uz": "Do‘kon holatini o‘zgartirib bo‘lmadi: {0}",
    "ru": "Не удалось изменить статус магазина: {0}",
    "en": "Could not update store status: {0}"
  },
  "m117": {"uz": "Do‘kon qarzi", "ru": "Долг магазина", "en": "Store debt"},
  "m118": {
    "uz": "Do‘kon telefoni",
    "ru": "Телефон магазина",
    "en": "Store phone"
  },
  "m119": {"uz": "Do‘kon: {0}", "ru": "Магазин: {0}", "en": "Store: {0}"},
  "m120": {"uz": "Do‘konlar", "ru": "Магазины", "en": "Stores"},
  "m121": {
    "uz": "Do‘konni bloklash",
    "ru": "Заблокировать магазин",
    "en": "Block store"
  },
  "m122": {
    "uz": "Do‘konni faollashtirish",
    "ru": "Активировать магазин",
    "en": "Activate store"
  },
  "m123": {"uz": "Egasi", "ru": "Владелец", "en": "Owner"},
  "m124": {
    "uz": "Egasi: {0} · Tarif: {1} · {2}\nTrial: {3} · To‘langan: {4}",
    "ru": "Владелец: {0} · Тариф: {1} · {2}\nПробный: {3} · Оплачено: {4}",
    "en": "Owner: {0} · Plan: {1} · {2}\nTrial: {3} · Paid: {4}"
  },
  "m125": {
    "uz": "Egasi: {0} · {1}\nID: {2} · {3}",
    "ru": "Владелец: {0} · {1}\nID: {2} · {3}",
    "en": "Owner: {0} · {1}\nID: {2} · {3}"
  },
  "m126": {"uz": "Email", "ru": "Эл. почта", "en": "Email"},
  "m127": {
    "uz": "Endi tizimga kirish mumkin",
    "ru": "Теперь можно войти",
    "en": "You can now sign in"
  },
  "m128": {
    "uz": "Endi username va yangi parolingiz bilan kirishingiz mumkin.",
    "ru": "Войдите с именем пользователя и новым паролем.",
    "en": "Sign in with your username and new password."
  },
  "m129": {
    "uz": "Eng eski qarz",
    "ru": "Самый старый долг",
    "en": "Oldest debt"
  },
  "m130": {
    "uz": "Eng katta qarz",
    "ru": "Самый большой долг",
    "en": "Largest debt"
  },
  "m131": {"uz": "Familiya", "ru": "Фамилия", "en": "Last name"},
  "m132": {"uz": "Faol", "ru": "Активен", "en": "Active"},
  "m133": {
    "uz": "Faol / bloklangan do‘konlar",
    "ru": "Активные / заблокированные магазины",
    "en": "Active / blocked stores"
  },
  "m134": {"uz": "Faol emas", "ru": "Неактивен", "en": "Inactive"},
  "m135": {
    "uz": "Faol mahsulot limiti",
    "ru": "Лимит активных товаров",
    "en": "Active product limit"
  },
  "m136": {
    "uz":
        "Faol muddatning qolgan qismi saqlanadi. Yakuniy tugash sanasini server hisoblaydi.",
    "ru":
        "Оставшийся оплаченный срок сохраняется. Итоговую дату рассчитывает сервер.",
    "en":
        "The remaining paid period is preserved. The server calculates the final expiry date."
  },
  "m137": {
    "uz": "Faol obunalar",
    "ru": "Активные подписки",
    "en": "Active subscriptions"
  },
  "m138": {
    "uz": "Faol userlar",
    "ru": "Активные пользователи",
    "en": "Active users"
  },
  "m139": {"uz": "Faollashtirish", "ru": "Активировать", "en": "Activate"},
  "m140": {"uz": "Filtrlar", "ru": "Фильтры", "en": "Filters"},
  "m141": {
    "uz": "Filtrlarni o'zgartiring yoki qidiruvni tozalang",
    "ru": "Измените фильтры или очистите поиск",
    "en": "Change filters or clear the search"
  },
  "m142": {"uz": "Foydalanuvchi", "ru": "Пользователь", "en": "User"},
  "m143": {
    "uz": "Foydalanuvchi nomi",
    "ru": "Имя пользователя",
    "en": "Username"
  },
  "m144": {
    "uz": "Foydalanuvchi nomi *",
    "ru": "Имя пользователя *",
    "en": "Username *"
  },
  "m145": {
    "uz": "Foydalanuvchiga aktivatsiya kodini bering",
    "ru": "Передайте пользователю код активации",
    "en": "Give the user their activation code"
  },
  "m146": {"uz": "Foydalanuvchilar", "ru": "Пользователи", "en": "Users"},
  "m147": {
    "uz": "Foydalanuvchilarni ko'rish",
    "ru": "Просмотр пользователей",
    "en": "View users"
  },
  "m148": {
    "uz": "Foydalanuvchilarni yuklashda xatolik: {0}",
    "ru": "Ошибка загрузки пользователей: {0}",
    "en": "Could not load users: {0}"
  },
  "m149": {
    "uz": "Galereya ruxsati berilmagan. Sozlamalardan ruxsatni yoqing.",
    "ru": "Нет доступа к галерее. Разрешите его в настройках.",
    "en": "Gallery access denied. Enable it in settings."
  },
  "m150": {"uz": "Galereyadan", "ru": "Из галереи", "en": "From gallery"},
  "m151": {"uz": "Grid ko'rinish", "ru": "Сетка", "en": "Grid view"},
  "m153": {
    "uz": "HTTP {0}: server xatosi",
    "ru": "HTTP {0}: ошибка сервера",
    "en": "HTTP {0}: server error"
  },
  "m154": {
    "uz": "Ha, arxivlash",
    "ru": "Да, архивировать",
    "en": "Yes, archive"
  },
  "m155": {"uz": "Ha, chiqish", "ru": "Да, выйти", "en": "Yes, sign out"},
  "m156": {"uz": "Ha, o'chirish", "ru": "Да, удалить", "en": "Yes, delete"},
  "m157": {"uz": "Ha, tozalash", "ru": "Да, очистить", "en": "Yes, clear"},
  "m158": {
    "uz": "Hech narsa topilmadi",
    "ru": "Ничего не найдено",
    "en": "Nothing found"
  },
  "m159": {
    "uz": "Hisob sozlamalari",
    "ru": "Настройки аккаунта",
    "en": "Account settings"
  },
  "m160": {
    "uz": "Hisobingiz aktivatsiya qilindi",
    "ru": "Аккаунт активирован",
    "en": "Account activated"
  },
  "m161": {
    "uz": "Hisobni aktivatsiya qilish",
    "ru": "Активировать аккаунт",
    "en": "Activate account"
  },
  "m162": {"uz": "Hisobot", "ru": "Отчёты", "en": "Reports"},
  "m163": {"uz": "Holat", "ru": "Статус", "en": "Status"},
  "m164": {"uz": "Holat: {0}", "ru": "Статус: {0}", "en": "Status: {0}"},
  "m165": {"uz": "Holati", "ru": "Статус", "en": "Status"},
  "m166": {
    "uz": "Hozircha mahsulot yo'q",
    "ru": "Товаров пока нет",
    "en": "No products yet"
  },
  "m167": {
    "uz": "Hozircha qarz yozuvi yo‘q",
    "ru": "Долгов пока нет",
    "en": "No debts yet"
  },
  "m168": {
    "uz": "Hozircha yozuv yo‘q",
    "ru": "Записей пока нет",
    "en": "No entries yet"
  },
  "m169": {
    "uz": "Hozirgi to‘langan muddat: {0}",
    "ru": "Оплачено до: {0}",
    "en": "Currently paid until: {0}"
  },
  "m170": {"uz": "Ilova mavzusi", "ru": "Тема приложения", "en": "App theme"},
  "m171": {
    "uz": "Imkoniyatlar (har satrga bittadan)",
    "ru": "Возможности (по одной в строке)",
    "en": "Features (one per line)"
  },
  "m172": {
    "uz": "Internet aloqasini tekshiring",
    "ru": "Проверьте подключение к интернету",
    "en": "Check your internet connection"
  },
  "m173": {
    "uz": "Internet yo‘q — qoldiq keshlangan ma’lumotdan olingan.",
    "ru": "Нет интернета — показан сохранённый остаток.",
    "en": "Offline — showing cached stock."
  },
  "m174": {
    "uz":
        "Internet yo‘q: qoldiq keshlangan va yangilanmagan bo‘lishi mumkin. Savdo serverda tekshiriladi.",
    "ru":
        "Нет интернета: остаток может быть устаревшим. Сервер проверит продажу.",
    "en":
        "Offline: cached stock may be outdated. The server will validate the sale."
  },
  "m175": {
    "uz": "Inventarizatsiya, nosozlik, va h.k.",
    "ru": "Инвентаризация, повреждение и т. п.",
    "en": "Stocktake, damage, etc."
  },
  "m176": {"uz": "Ism", "ru": "Имя", "en": "First name"},
  "m177": {"uz": "Ism familiya", "ru": "Имя и фамилия", "en": "Full name"},
  "m178": {
    "uz": "Ism va musbat summa kiriting",
    "ru": "Введите имя и положительную сумму",
    "en": "Enter a name and a positive amount"
  },
  "m179": {
    "uz": "Ism yoki tashkilot",
    "ru": "Имя или организация",
    "en": "Name or organization"
  },
  "m180": {
    "uz": "Ism yoki telefon",
    "ru": "Имя или телефон",
    "en": "Name or phone"
  },
  "m181": {"uz": "Ixtiyoriy", "ru": "Необязательно", "en": "Optional"},
  "m182": {"uz": "Izoh", "ru": "Комментарий", "en": "Note"},
  "m183": {
    "uz": "Izoh (ixtiyoriy)",
    "ru": "Комментарий (необязательно)",
    "en": "Note (optional)"
  },
  "m184": {
    "uz": "JPG, PNG yoki WebP rasm tanlang.",
    "ru": "Выберите изображение JPG, PNG или WebP.",
    "en": "Select a JPG, PNG or WebP image."
  },
  "m185": {"uz": "Jami", "ru": "Итого", "en": "Total"},
  "m186": {
    "uz": "Jami mahsulotlar",
    "ru": "Всего товаров",
    "en": "Total products"
  },
  "m187": {"uz": "Jami qoldiq", "ru": "Общий остаток", "en": "Total stock"},
  "m188": {"uz": "Jami:", "ru": "Итого:", "en": "Total:"},
  "m189": {
    "uz": "Joriy parol",
    "ru": "Текущий пароль",
    "en": "Current password"
  },
  "m190": {
    "uz": "Joriy parolni kiriting",
    "ru": "Введите текущий пароль",
    "en": "Enter your current password"
  },
  "m191": {
    "uz": "Joriy qoldiq",
    "ru": "Текущий остаток",
    "en": "Current stock"
  },
  "m192": {
    "uz": "Joriy qoldiq:",
    "ru": "Текущий остаток:",
    "en": "Current stock:"
  },
  "m193": {
    "uz": "Joriy qoldiq: {0} {1}",
    "ru": "Текущий остаток: {0} {1}",
    "en": "Current stock: {0} {1}"
  },
  "m194": {"uz": "Joriy tarif", "ru": "Текущий тариф", "en": "Current plan"},
  "m195": {"uz": "Kam qolgan", "ru": "Мало на складе", "en": "Low stock"},
  "m196": {
    "uz": "Kam qolgan mahsulotlar yo‘q.",
    "ru": "Товаров с низким остатком нет.",
    "en": "No low-stock products."
  },
  "m197": {"uz": "Kamera", "ru": "Камера", "en": "Camera"},
  "m198": {
    "uz": "Kamera javobi kutilmoqda...",
    "ru": "Ожидание ответа камеры…",
    "en": "Waiting for camera…"
  },
  "m199": {
    "uz": "Kamera ochilishida xato",
    "ru": "Не удалось открыть камеру",
    "en": "Could not open camera"
  },
  "m200": {
    "uz": "Kamera ochilmoqda...",
    "ru": "Запуск камеры…",
    "en": "Starting camera…"
  },
  "m201": {
    "uz": "Kamera ruxsati berilmagan",
    "ru": "Нет разрешения на камеру",
    "en": "Camera permission denied"
  },
  "m202": {
    "uz": "Kamera ruxsati berilmagan. Sozlamalardan ruxsatni yoqing.",
    "ru": "Нет доступа к камере. Разрешите его в настройках.",
    "en": "Camera access denied. Enable it in settings."
  },
  "m203": {
    "uz": "Kamera yopilmoqda...",
    "ru": "Закрытие камеры…",
    "en": "Closing camera…"
  },
  "m204": {"uz": "Karta", "ru": "Карта", "en": "Card"},
  "m205": {
    "uz": "Karta orqali to‘lov",
    "ru": "Оплата картой",
    "en": "Card payment"
  },
  "m206": {
    "uz":
        "Karta summasi bu yerda qayd qilinadi. Ilova bank kartasidan pul yechmaydi.",
    "ru":
        "Здесь учитывается сумма по карте. Приложение не списывает деньги с карты.",
    "en":
        "The card amount is recorded here. The app does not charge bank cards."
  },
  "m207": {
    "uz": "Karta summasi to‘lov summasiga teng bo‘lishi kerak.",
    "ru": "Сумма по карте должна совпадать с суммой оплаты.",
    "en": "The card amount must match the amount due."
  },
  "m208": {"uz": "Karta:", "ru": "Карта:", "en": "Card:"},
  "m209": {"uz": "Karta: {0}%", "ru": "Карта: {0}%", "en": "Card: {0}%"},
  "m210": {"uz": "Kassa", "ru": "Касса", "en": "POS"},
  "m211": {"uz": "Kategoriasiz", "ru": "Без категории", "en": "Uncategorized"},
  "m212": {"uz": "Kategoriya", "ru": "Категория", "en": "Category"},
  "m213": {
    "uz": "Kategoriyalar yuklanmadi",
    "ru": "Не удалось загрузить категории",
    "en": "Could not load categories"
  },
  "m214": {"uz": "Kecha", "ru": "Вчера", "en": "Yesterday"},
  "m215": {
    "uz": "Keshlangan mahsulot qoldig‘i noto‘g‘ri.",
    "ru": "Некорректный сохранённый остаток.",
    "en": "Invalid cached product stock."
  },
  "m216": {"uz": "Keyinroq", "ru": "Позже", "en": "Later"},
  "m217": {"uz": "Kirish", "ru": "Войти", "en": "Sign in"},
  "m218": {
    "uz": "Kirish amalga oshmadi. Qayta urinib ko‘ring.",
    "ru": "Не удалось войти. Попробуйте снова.",
    "en": "Sign-in failed. Try again."
  },
  "m219": {
    "uz": "Kirish sahifasiga o'tish",
    "ru": "Перейти ко входу",
    "en": "Go to sign-in"
  },
  "m220": {
    "uz": "Kirish sahifasiga o‘tish",
    "ru": "Перейти ко входу",
    "en": "Go to sign-in"
  },
  "m221": {
    "uz": "Kirish sahifasiga qaytish",
    "ru": "Вернуться ко входу",
    "en": "Back to sign-in"
  },
  "m222": {
    "uz": "Kiritilgan ma’lumotlarni tekshiring.",
    "ru": "Проверьте введённые данные.",
    "en": "Check your input."
  },
  "m223": {"uz": "Kod berish", "ru": "Выдать код", "en": "Issue code"},
  "m224": {"uz": "Kod nusxalandi", "ru": "Код скопирован", "en": "Code copied"},
  "m225": {
    "uz": "Kodni kameraga ko‘rsating. Fokus uchun tasvirga teging.",
    "ru": "Наведите камеру на код. Нажмите на изображение для фокусировки.",
    "en": "Point the camera at the code. Tap the preview to focus."
  },
  "m226": {
    "uz": "Kodni skanerlang va Enter bosing",
    "ru": "Сканируйте код и нажмите Enter",
    "en": "Scan the code and press Enter"
  },
  "m227": {
    "uz": "Kodni xavfsiz kanal orqali bir marta yuboring",
    "ru": "Передайте код один раз по защищённому каналу",
    "en": "Share the code once through a secure channel"
  },
  "m228": {
    "uz": "Ko‘p urinish bo‘ldi. Biroz kuting.",
    "ru": "Слишком много попыток. Подождите немного.",
    "en": "Too many attempts. Please wait."
  },
  "m229": {
    "uz": "Kunlik sotuvlar",
    "ru": "Продажи по дням",
    "en": "Daily sales"
  },
  "m230": {
    "uz": "Kutilmagan xatolik: {0}",
    "ru": "Непредвиденная ошибка: {0}",
    "en": "Unexpected error: {0}"
  },
  "m231": {"uz": "Kutilmoqda", "ru": "Ожидание", "en": "Pending"},
  "m232": {"uz": "List ko'rinish", "ru": "Список", "en": "List view"},
  "m233": {
    "uz": "Login va parolni kiriting.",
    "ru": "Введите имя пользователя и пароль.",
    "en": "Enter your username and password."
  },
  "m234": {
    "uz": "Login yoki parol noto‘g‘ri.",
    "ru": "Неверное имя пользователя или пароль.",
    "en": "Incorrect username or password."
  },
  "m235": {"uz": "MAHSULOTLAR", "ru": "ТОВАРЫ", "en": "PRODUCTS"},
  "m236": {
    "uz": "Ma'lumot yuklanmadi",
    "ru": "Не удалось загрузить данные",
    "en": "Could not load data"
  },
  "m237": {"uz": "Mahsulot", "ru": "Товар", "en": "Product"},
  "m238": {
    "uz": "Mahsulot arxivlanadi va sotuvda ko'rinmaydi. Davom etasizmi?",
    "ru": "Товар будет архивирован и скрыт из продаж. Продолжить?",
    "en": "The product will be archived and hidden from sales. Continue?"
  },
  "m239": {
    "uz": "Mahsulot arxivlandi",
    "ru": "Товар архивирован",
    "en": "Product archived"
  },
  "m240": {
    "uz":
        "Mahsulot butunlay o'chiriladi. Bu amalni qaytarib bo'lmaydi. Davom etasizmi?",
    "ru":
        "Товар будет удалён из каталога. При наличии истории продаж или склада запись останется скрытой в базе для сохранения истории. Продолжить?",
    "en":
        "Remove this product from the catalogue? If sales or stock history exists, the database record is kept hidden to preserve that history."
  },
  "m241": {
    "uz": "Mahsulot kodi (SKU)",
    "ru": "Код товара (SKU)",
    "en": "Product code (SKU)"
  },
  "m242": {
    "uz": "Mahsulot kodi (SKU) *",
    "ru": "Код товара (SKU) *",
    "en": "Product code (SKU) *"
  },
  "m243": {
    "uz": "Mahsulot ma'lumotlari",
    "ru": "Сведения о товаре",
    "en": "Product information"
  },
  "m244": {
    "uz": "Mahsulot muvaffaqiyatli qo'shildi",
    "ru": "Товар добавлен",
    "en": "Product added"
  },
  "m245": {
    "uz": "Mahsulot nomi *",
    "ru": "Название товара *",
    "en": "Product name *"
  },
  "m246": {
    "uz": "Mahsulot nomini kiriting",
    "ru": "Введите название товара",
    "en": "Enter a product name"
  },
  "m247": {
    "uz": "Mahsulot o'chirildi",
    "ru": "Товар удалён",
    "en": "Product deleted"
  },
  "m248": {
    "uz": "Mahsulot qo'shish",
    "ru": "Добавить товар",
    "en": "Add product"
  },
  "m249": {
    "uz": "Mahsulot rasmi",
    "ru": "Изображение товара",
    "en": "Product image"
  },
  "m250": {
    "uz": "Mahsulot rasmini yuklash",
    "ru": "Загрузить изображение товара",
    "en": "Upload product image"
  },
  "m251": {
    "uz": "Mahsulot rasmisiz bo'ladi",
    "ru": "У товара не будет изображения",
    "en": "The product will have no image"
  },
  "m252": {
    "uz": "Mahsulot savdo yoki ombor tarixida mavjud. Uni arxivlang.",
    "ru": "Товар используется в истории продаж или склада. Архивируйте его.",
    "en": "The product has sales or inventory history. Archive it instead."
  },
  "m253": {
    "uz": "Mahsulot topilmadi",
    "ru": "Товар не найден",
    "en": "Product not found"
  },
  "m254": {
    "uz": "Mahsulot topilmadi yoki bu do‘konga tegishli emas.",
    "ru": "Товар не найден или принадлежит другому магазину.",
    "en": "Product not found or belongs to another store."
  },
  "m255": {"uz": "Mahsulotlar", "ru": "Товары", "en": "Products"},
  "m256": {
    "uz": "Mahsulotlar jami",
    "ru": "Сумма товаров",
    "en": "Products subtotal"
  },
  "m257": {"uz": "Mahsulotlar yo'q", "ru": "Товаров нет", "en": "No products"},
  "m258": {
    "uz": "Mahsulotlar yuklanmoqda...",
    "ru": "Загрузка товаров…",
    "en": "Loading products…"
  },
  "m259": {
    "uz": "Mahsulotlar: {0}",
    "ru": "Товары: {0}",
    "en": "Products: {0}"
  },
  "m260": {
    "uz": "Mahsulotlarni boshqarish",
    "ru": "Управление товарами",
    "en": "Manage products"
  },
  "m261": {
    "uz": "Mahsulotlarni serverdan yoki keshlangan ma’lumotdan olib bo‘lmadi.",
    "ru": "Не удалось получить товары с сервера или из кеша.",
    "en": "Could not load products from the server or cache."
  },
  "m262": {
    "uz": "Mahsulotlarni yuklashda xatolik. Internetni tekshiring.",
    "ru": "Ошибка загрузки товаров. Проверьте интернет.",
    "en": "Could not load products. Check your connection."
  },
  "m263": {
    "uz": "Mahsulotni arxivlash",
    "ru": "Архивировать товар",
    "en": "Archive product"
  },
  "m264": {
    "uz": "Mahsulotni o'chirish",
    "ru": "Удалить товар",
    "en": "Delete product"
  },
  "m265": {
    "uz": "Mahsulotni saqlash",
    "ru": "Сохранить товар",
    "en": "Save product"
  },
  "m266": {
    "uz": "Mahsulotni tahrirlash",
    "ru": "Редактировать товар",
    "en": "Edit product"
  },
  "m267": {
    "uz": "Mahsulotni tanlang va savatga qo'shing",
    "ru": "Выберите товар и добавьте в корзину",
    "en": "Select a product to add to the cart"
  },
  "m268": {
    "uz": "Masalan: Singan mahsulotlar",
    "ru": "Например: повреждённые товары",
    "en": "For example: damaged products"
  },
  "m269": {
    "uz": "Masalan: Yangi partiya keldi",
    "ru": "Например: поступила новая партия",
    "en": "For example: new stock arrived"
  },
  "m270": {"uz": "Mavjud", "ru": "В наличии", "en": "In stock"},
  "m271": {"uz": "Mavjud emas", "ru": "Нет в наличии", "en": "Unavailable"},
  "m272": {
    "uz": "Mavjud rasmdan tanlash",
    "ru": "Выбрать существующее изображение",
    "en": "Choose an existing image"
  },
  "m273": {
    "uz": "Mavjud: {0} {1}",
    "ru": "В наличии: {0} {1}",
    "en": "Available: {0} {1}"
  },
  "m274": {
    "uz": "Mavzu saqlanmadi. Qayta urinib ko‘ring.",
    "ru": "Не удалось сохранить тему. Попробуйте снова.",
    "en": "Could not save the theme. Try again."
  },
  "m275": {"uz": "Max: {0} {1}", "ru": "Макс.: {0} {1}", "en": "Max: {0} {1}"},
  "m276": {
    "uz": "Ma’lumot topilmadi",
    "ru": "Данные не найдены",
    "en": "No data found"
  },
  "m277": {"uz": "Ma’lumotlar bazasi", "ru": "База данных", "en": "Database"},
  "m278": {
    "uz": "Ma’lumotlarni yuklab bo‘lmadi. Qayta urinib ko‘ring.",
    "ru": "Не удалось загрузить данные. Попробуйте снова.",
    "en": "Could not load data. Try again."
  },
  "m279": {
    "uz": "Ma’lumotni yuklab bo‘lmadi. Qayta urinib ko‘ring.",
    "ru": "Не удалось загрузить данные. Попробуйте снова.",
    "en": "Could not load data. Try again."
  },
  "m280": {
    "uz": "Mijoz bergan naqd pul",
    "ru": "Наличные от клиента",
    "en": "Cash received"
  },
  "m281": {"uz": "Mijoz nomi", "ru": "Имя клиента", "en": "Customer name"},
  "m282": {
    "uz": "Mijoz nomini kiriting.",
    "ru": "Введите имя клиента.",
    "en": "Enter a customer name."
  },
  "m283": {
    "uz": "Mijozdan olinadi",
    "ru": "Получить от клиента",
    "en": "Receivable from customer"
  },
  "m284": {
    "uz": "Minimal qoldiq",
    "ru": "Минимальный остаток",
    "en": "Minimum stock"
  },
  "m285": {"uz": "Miqdor", "ru": "Количество", "en": "Quantity"},
  "m286": {"uz": "Miqdor *", "ru": "Количество *", "en": "Quantity *"},
  "m287": {
    "uz": "Miqdor noldan katta bo‘lishi kerak.",
    "ru": "Количество должно быть больше нуля.",
    "en": "Quantity must be greater than zero."
  },
  "m288": {
    "uz": "Miqdorni kiriting",
    "ru": "Введите количество",
    "en": "Enter quantity"
  },
  "m289": {"uz": "Muddat", "ru": "Срок", "en": "Due date"},
  "m290": {"uz": "Muddat (oy)", "ru": "Срок (месяцы)", "en": "Term (months)"},
  "m291": {"uz": "Muddat qo‘shish", "ru": "Добавить срок", "en": "Extend term"},
  "m292": {"uz": "Muddati o‘tgan", "ru": "Просрочено", "en": "Expired"},
  "m293": {"uz": "Muddati o‘tganlar", "ru": "Просроченные", "en": "Overdue"},
  "m294": {
    "uz": "Muddatni olib tashlash",
    "ru": "Убрать срок",
    "en": "Remove due date"
  },
  "m295": {
    "uz": "Muddatni uzaytirish",
    "ru": "Продлить срок",
    "en": "Extend term"
  },
  "m296": {"uz": "Muvaffaqiyatli!", "ru": "Готово!", "en": "Success!"},
  "m297": {"uz": "Muvaffaqiyatsiz", "ru": "Ошибка", "en": "Failed"},
  "m298": {"uz": "Naqd", "ru": "Наличные", "en": "Cash"},
  "m299": {"uz": "Naqd + karta", "ru": "Наличные + карта", "en": "Cash + card"},
  "m300": {"uz": "Naqd pul", "ru": "Наличные", "en": "Cash"},
  "m301": {
    "uz": "Naqd pul miqdorini tekshiring.",
    "ru": "Проверьте сумму наличных.",
    "en": "Check the cash amount."
  },
  "m302": {
    "uz": "Naqd va karta summalarini tekshiring.",
    "ru": "Проверьте суммы наличных и карты.",
    "en": "Check the cash and card amounts."
  },
  "m303": {"uz": "Naqd:", "ru": "Наличные:", "en": "Cash:"},
  "m304": {"uz": "Naqd: {0}%", "ru": "Наличные: {0}%", "en": "Cash: {0}%"},
  "m305": {"uz": "Narx (so‘m)", "ru": "Цена (сум)", "en": "Price (UZS)"},
  "m306": {"uz": "Narx oralig'i", "ru": "Диапазон цен", "en": "Price range"},
  "m307": {"uz": "Narxlar", "ru": "Цены", "en": "Prices"},
  "m309": {"uz": "Noma'lum", "ru": "Неизвестно", "en": "Unknown"},
  "m310": {"uz": "Nomi", "ru": "Название", "en": "Name"},
  "m311": {"uz": "Nusxalash", "ru": "Копировать", "en": "Copy"},
  "m312": {"uz": "O'chirish", "ru": "Удалить", "en": "Delete"},
  "m313": {"uz": "O'lchov birligi", "ru": "Единица измерения", "en": "Unit"},
  "m314": {
    "uz": "O'lchov birligi *",
    "ru": "Единица измерения *",
    "en": "Unit *"
  },
  "m315": {
    "uz": "O'lchov birligi tanlang",
    "ru": "Выберите единицу измерения",
    "en": "Select a unit"
  },
  "m316": {"uz": "O'sish tartibida", "ru": "По возрастанию", "en": "Ascending"},
  "m317": {
    "uz": "O'zgarishlar saqlandi",
    "ru": "Изменения сохранены",
    "en": "Changes saved"
  },
  "m318": {
    "uz": "O'zgarishlarni bekor qilish?",
    "ru": "Отменить изменения?",
    "en": "Discard changes?"
  },
  "m319": {
    "uz": "O'zgarishlarni saqlash",
    "ru": "Сохранить изменения",
    "en": "Save changes"
  },
  "m320": {"uz": "O'zgartirilmoqda...", "ru": "Обновление…", "en": "Updating…"},
  "m321": {"uz": "OK", "ru": "ОК", "en": "OK"},
  "m322": {"uz": "Obuna", "ru": "Подписка", "en": "Subscription"},
  "m323": {
    "uz": "Obuna bekor qilindi.",
    "ru": "Подписка отменена.",
    "en": "Subscription cancelled."
  },
  "m324": {
    "uz": "Obuna holati",
    "ru": "Статус подписки",
    "en": "Subscription status"
  },
  "m325": {
    "uz":
        "Obuna muddati darhol tugatiladi. Bu amal foydalanuvchi ma’lumotlarini o‘chirmaydi.",
    "ru":
        "Подписка закончится немедленно. Данные пользователя не будут удалены.",
    "en":
        "The subscription will end immediately. User data will not be deleted."
  },
  "m326": {
    "uz":
        "Obuna muddati tugagan. Amalni davom ettirish uchun obunani yangilang.",
    "ru": "Подписка истекла. Продлите её для продолжения.",
    "en": "Subscription expired. Renew it to continue."
  },
  "m327": {
    "uz": "Obuna yozuvlari mavjud emas",
    "ru": "Записей о подписках нет",
    "en": "No subscription records"
  },
  "m328": {
    "uz": "Obuna {0} oyga uzaytirildi.{1}",
    "ru": "Подписка продлена на {0} мес. {1}",
    "en": "Subscription extended by {0} months. {1}"
  },
  "m329": {
    "uz": "Obuna: {0}",
    "ru": "Подписка: {0}",
    "en": "Subscription: {0}"
  },
  "m330": {"uz": "Obunalar", "ru": "Подписки", "en": "Subscriptions"},
  "m331": {
    "uz": "Obunalar tarixi",
    "ru": "История подписок",
    "en": "Subscription history"
  },
  "m332": {
    "uz": "Obunani bekor qilish",
    "ru": "Отменить подписку",
    "en": "Cancel subscription"
  },
  "m333": {
    "uz": "Obunani uzaytirish",
    "ru": "Продлить подписку",
    "en": "Extend subscription"
  },
  "m334": {
    "uz": "Offline bazani ochish uchun akkauntga kirish kerak.",
    "ru": "Для открытия офлайн-базы войдите в аккаунт.",
    "en": "Sign in to open the offline database."
  },
  "m335": {
    "uz": "Ogohlantirish uchun",
    "ru": "Для предупреждения",
    "en": "Warning threshold"
  },
  "m336": {"uz": "Olinadigan", "ru": "К получению", "en": "Receivable"},
  "m337": {"uz": "Ombor", "ru": "Склад", "en": "Inventory"},
  "m338": {
    "uz": "Ombor sozlamalari",
    "ru": "Настройки склада",
    "en": "Inventory settings"
  },
  "m339": {
    "uz": "Ombor tarixi tez orada qo'shiladi",
    "ru": "История склада пока недоступна",
    "en": "Inventory history is not yet available"
  },
  "m340": {
    "uz": "Ombor tarixini ko'rish",
    "ru": "История склада",
    "en": "View inventory history"
  },
  "m341": {
    "uz": "Omborda mahsulot qolmagan. Chegara: {0}",
    "ru": "Товара на складе нет. Порог: {0}",
    "en": "Out of stock. Threshold: {0}"
  },
  "m342": {
    "uz": "Omborda mahsulot qolmagan. Ogohlantirish chegarasi: {0} {1}.",
    "ru": "Товара на складе нет. Порог предупреждения: {0} {1}.",
    "en": "Out of stock. Warning threshold: {0} {1}."
  },
  "m343": {
    "uz": "Omborda yetarli mahsulot yo‘q.",
    "ru": "Недостаточно товара на складе.",
    "en": "Insufficient stock."
  },
  "m344": {
    "uz": "Omborda {0} dona. Ogohlantirish chegarasi: {1} dona.",
    "ru": "На складе {0} шт. Порог предупреждения: {1} шт.",
    "en": "Stock: {0} units. Warning threshold: {1} units."
  },
  "m345": {
    "uz": "Omborda {0} {1}. Ogohlantirish chegarasi: {2} {3}.",
    "ru": "На складе {0} {1}. Порог предупреждения: {2} {3}.",
    "en": "Stock: {0} {1}. Warning threshold: {2} {3}."
  },
  "m346": {
    "uz": "Ombordagi holati",
    "ru": "Состояние склада",
    "en": "Stock status"
  },
  "m347": {
    "uz": "Operatsiya ID si boshqa sotuvga tegishli.",
    "ru": "ID операции принадлежит другой продаже.",
    "en": "This operation ID belongs to another sale."
  },
  "m348": {"uz": "Ortga", "ru": "Назад", "en": "Back"},
  "m349": {
    "uz": "Oxirgi yangilanish",
    "ru": "Последнее обновление",
    "en": "Last updated"
  },
  "m350": {
    "uz": "O‘rtacha chek: {0} so‘m",
    "ru": "Средний чек: {0} сум",
    "en": "Average sale: {0} UZS"
  },
  "m351": {"uz": "O‘tib ketgan", "ru": "Просрочено", "en": "Overdue"},
  "m352": {
    "uz": "O‘zgarishlarni saqlab bo‘lmadi",
    "ru": "Не удалось сохранить изменения",
    "en": "Could not save changes"
  },
  "m353": {"uz": "PDF", "ru": "PDF", "en": "PDF"},
  "m354": {
    "uz": "PDF eksport tez orada...",
    "ru": "Экспорт PDF пока недоступен",
    "en": "PDF export is not yet available"
  },
  "m356": {"uz": "Parol", "ru": "Пароль", "en": "Password"},
  "m357": {
    "uz": "Parol kamida 10 ta belgidan iborat bo‘lishi kerak",
    "ru": "Пароль должен содержать не менее 10 символов",
    "en": "Password must contain at least 10 characters"
  },
  "m358": {
    "uz": "Parol o'zgartirish majburiy",
    "ru": "Необходимо изменить пароль",
    "en": "Password change required"
  },
  "m359": {
    "uz": "Parol talablari:",
    "ru": "Требования к паролю:",
    "en": "Password requirements:"
  },
  "m360": {
    "uz": "Parolingiz o'zgartirildi",
    "ru": "Пароль изменён",
    "en": "Password changed"
  },
  "m361": {
    "uz": "Parolingizni yangilang",
    "ru": "Обновите пароль",
    "en": "Update your password"
  },
  "m362": {
    "uz": "Parollar mos kelmadi",
    "ru": "Пароли не совпадают",
    "en": "Passwords do not match"
  },
  "m363": {
    "uz": "Parolni kiriting",
    "ru": "Введите пароль",
    "en": "Enter a password"
  },
  "m364": {
    "uz": "Parolni o'zgartirish",
    "ru": "Изменить пароль",
    "en": "Change password"
  },
  "m365": {
    "uz": "Parolni o‘zgartirish",
    "ru": "Изменить пароль",
    "en": "Change password"
  },
  "m366": {
    "uz": "Parolni tasdiqlang",
    "ru": "Подтвердите пароль",
    "en": "Confirm password"
  },
  "m367": {
    "uz": "Parolni yangilash",
    "ru": "Обновить пароль",
    "en": "Update password"
  },
  "m368": {"uz": "Plastik karta", "ru": "Банковская карта", "en": "Bank card"},
  "m369": {"uz": "Profil", "ru": "Профиль", "en": "Profile"},
  "m370": {
    "uz": "Profil javobida foydalanuvchi ID mavjud emas.",
    "ru": "В ответе профиля нет ID пользователя.",
    "en": "The profile response is missing the user ID."
  },
  "m371": {
    "uz": "Profil ma’lumotlari",
    "ru": "Сведения профиля",
    "en": "Profile information"
  },
  "m372": {
    "uz": "Profil yangilandi",
    "ru": "Профиль обновлён",
    "en": "Profile updated"
  },
  "m373": {
    "uz": "Profilni tahrirlash",
    "ru": "Редактировать профиль",
    "en": "Edit profile"
  },
  "m374": {"uz": "Qabul qilish", "ru": "Принять", "en": "Accept"},
  "m375": {"uz": "Qarz", "ru": "Долг", "en": "Debt"},
  "m376": {
    "uz": "Qarz ma’lumotlarini tahrirlash",
    "ru": "Редактировать долг",
    "en": "Edit debt"
  },
  "m377": {
    "uz": "Qarz miqdori avtomatik ravishda daftar qarziga yoziladi.",
    "ru": "Сумма автоматически добавляется в долговую книгу.",
    "en": "The amount is automatically added to the debt ledger."
  },
  "m378": {
    "uz": "Qarz saqlanmadi. Internetni tekshirib qayta urinib ko‘ring.",
    "ru": "Не удалось сохранить долг. Проверьте интернет и повторите попытку.",
    "en": "Could not save debt. Check your connection and try again."
  },
  "m379": {"uz": "Qarz turi", "ru": "Тип долга", "en": "Debt type"},
  "m380": {
    "uz": "Qarzli mijozlar",
    "ru": "Клиенты с долгами",
    "en": "Customers with debt"
  },
  "m381": {"uz": "Qayta urinish", "ru": "Повторить", "en": "Try again"},
  "m382": {
    "uz": "Qayta urinish uchun dastlabki sotuv ma’lumotlari saqlangan.",
    "ru": "Для повтора сохранены исходные данные продажи.",
    "en": "The original sale details are saved for retry."
  },
  "m383": {"uz": "Qayta yuklash", "ru": "Обновить", "en": "Reload"},
  "m384": {
    "uz": "Qaytib kelib turing",
    "ru": "Заглядывайте снова",
    "en": "Check back later"
  },
  "m385": {"uz": "Qaytim", "ru": "Сдача", "en": "Change"},
  "m386": {"uz": "Qaytish", "ru": "Назад", "en": "Back"},
  "m387": {"uz": "Qidirish", "ru": "Поиск", "en": "Search"},
  "m388": {
    "uz": "Qidirish (nom, kod, shtrix-kod)...",
    "ru": "Поиск по названию, коду, штрихкоду…",
    "en": "Search by name, code or barcode…"
  },
  "m389": {
    "uz": "Qidiruv bo‘yicha user topilmadi",
    "ru": "Пользователь не найден",
    "en": "No matching users"
  },
  "m390": {"uz": "Qisman", "ru": "Частично", "en": "Partial"},
  "m391": {
    "uz": "Qisman to‘langan",
    "ru": "Частично оплачено",
    "en": "Partially paid"
  },
  "m392": {"uz": "Qo'llash", "ru": "Применить", "en": "Apply"},
  "m393": {"uz": "Qo'sh", "ru": "Добавить", "en": "Add"},
  "m394": {"uz": "Qo'shildi", "ru": "Добавлено", "en": "Added"},
  "m395": {"uz": "Qo'shish", "ru": "Добавить", "en": "Add"},
  "m396": {"uz": "Qoldiq", "ru": "Остаток", "en": "Stock"},
  "m397": {
    "uz": "Qoldiq manfiy bo'lishi mumkin emas",
    "ru": "Остаток не может быть отрицательным",
    "en": "Stock cannot be negative"
  },
  "m398": {
    "uz": "Qoldiq {0}: {1} {2}",
    "ru": "Остаток {0}: {1} {2}",
    "en": "Stock {0}: {1} {2}"
  },
  "m399": {"uz": "Qoldiq: {0}", "ru": "Остаток: {0}", "en": "Stock: {0}"},
  "m400": {
    "uz": "Qoldiqni boshqarish",
    "ru": "Управление остатками",
    "en": "Manage stock"
  },
  "m401": {
    "uz":
        "Qoldiqni bu yerdan o'zgartirish mumkin emas. \"Qoldiqni o'zgartirish\" tugmasidan foydalaning.",
    "ru":
        "Здесь нельзя изменить остаток. Используйте кнопку «Изменить остаток».",
    "en": "Stock cannot be changed here. Use the stock adjustment button."
  },
  "m402": {
    "uz": "Qoldiqni o'zgartirish",
    "ru": "Изменить остаток",
    "en": "Adjust stock"
  },
  "m403": {"uz": "Qolish", "ru": "Остаться", "en": "Stay"},
  "m404": {"uz": "Qorong‘i", "ru": "Тёмная", "en": "Dark"},
  "m405": {"uz": "RAHMAT!", "ru": "СПАСИБО!", "en": "THANK YOU!"},
  "m406": {
    "uz": "Rasm hajmi 5 MB dan oshmasligi kerak.",
    "ru": "Размер изображения не должен превышать 5 МБ.",
    "en": "Image size must not exceed 5 MB."
  },
  "m407": {
    "uz": "Rasm o'chirildi",
    "ru": "Изображение удалено",
    "en": "Image removed"
  },
  "m408": {
    "uz": "Rasm yuklandi",
    "ru": "Изображение загружено",
    "en": "Image uploaded"
  },
  "m409": {
    "uz": "Rasm yuklash",
    "ru": "Загрузить изображение",
    "en": "Upload image"
  },
  "m410": {
    "uz": "Rasmni o'chirish",
    "ru": "Удалить изображение",
    "en": "Remove image"
  },
  "m411": {
    "uz": "Rasmni o'zgartirish",
    "ru": "Изменить изображение",
    "en": "Change image"
  },
  "m412": {
    "uz": "Rasmni tanlab bo‘lmadi.",
    "ru": "Не удалось выбрать изображение.",
    "en": "Could not select an image."
  },
  "m413": {"uz": "Rol", "ru": "Роль", "en": "Role"},
  "m414": {
    "uz": "Ro‘yxatdan o‘tgan",
    "ru": "Зарегистрирован",
    "en": "Registered"
  },
  "m415": {"uz": "SKU kiriting", "ru": "Введите SKU", "en": "Enter SKU"},
  "m416": {"uz": "Sabab", "ru": "Причина", "en": "Reason"},
  "m417": {
    "uz": "Sabab (majburiy)",
    "ru": "Причина (обязательно)",
    "en": "Reason (required)"
  },
  "m418": {
    "uz": "Sabab / tavsif",
    "ru": "Причина / описание",
    "en": "Reason / description"
  },
  "m419": {"uz": "Sabab: {0}", "ru": "Причина: {0}", "en": "Reason: {0}"},
  "m420": {
    "uz": "Sababni kiriting",
    "ru": "Укажите причину",
    "en": "Enter a reason"
  },
  "m421": {"uz": "Sana", "ru": "Дата", "en": "Date"},
  "m422": {"uz": "Sana:", "ru": "Дата:", "en": "Date:"},
  "m423": {"uz": "Sana: {0}", "ru": "Дата: {0}", "en": "Date: {0}"},
  "m424": {
    "uz":
        "Saqlangan mahsulotlar yo‘q. Internet bilan mahsulotlarni bir marta yuklang.",
    "ru": "Нет сохранённых товаров. Сначала загрузите товары через интернет.",
    "en": "No cached products. Load products online first."
  },
  "m425": {"uz": "Saqlanmoqda...", "ru": "Сохранение…", "en": "Saving…"},
  "m426": {"uz": "Saqlash", "ru": "Сохранить", "en": "Save"},
  "m427": {
    "uz": "Saqlashdan oldin chiqsangiz, barcha o'zgarishlar yo'qoladi.",
    "ru": "Если выйти до сохранения, все изменения будут потеряны.",
    "en": "Leaving before saving will discard your changes."
  },
  "m428": {"uz": "Saralash", "ru": "Сортировка", "en": "Sort"},
  "m429": {"uz": "Savat", "ru": "Корзина", "en": "Cart"},
  "m430": {"uz": "Savat bo'sh", "ru": "Корзина пуста", "en": "Cart is empty"},
  "m431": {
    "uz": "Savat bo'sh — mahsulot qo'shing",
    "ru": "Корзина пуста — добавьте товары",
    "en": "Cart is empty — add products"
  },
  "m432": {
    "uz": "Savat bo‘sh.",
    "ru": "Корзина пуста.",
    "en": "Cart is empty."
  },
  "m433": {
    "uz": "Savat summasi noto‘g‘ri.",
    "ru": "Некорректная сумма корзины.",
    "en": "Invalid cart total."
  },
  "m434": {
    "uz": "Savat tozalandi",
    "ru": "Корзина очищена",
    "en": "Cart cleared"
  },
  "m435": {"uz": "Savatda", "ru": "В корзине", "en": "In cart"},
  "m436": {
    "uz": "Savatni tozalash",
    "ru": "Очистить корзину",
    "en": "Clear cart"
  },
  "m437": {"uz": "Savdo cheki", "ru": "Товарный чек", "en": "Sales receipt"},
  "m438": {
    "uz": "Savdo muvaffaqiyatli yakunlandi!",
    "ru": "Продажа завершена!",
    "en": "Sale completed!"
  },
  "m439": {
    "uz": "Savdo va ombor holati",
    "ru": "Продажи и склад",
    "en": "Sales and inventory"
  },
  "m440": {
    "uz": "Server access token qaytarmadi.",
    "ru": "Сервер не вернул токен доступа.",
    "en": "The server did not return an access token."
  },
  "m441": {
    "uz": "Server bilan aloqa yo'q",
    "ru": "Нет связи с сервером",
    "en": "No server connection"
  },
  "m442": {
    "uz": "Server bilan bog‘lanishda xatolik yuz berdi. Qayta urinib ko‘ring.",
    "ru": "Ошибка связи с сервером. Попробуйте снова.",
    "en": "Could not reach the server. Try again."
  },
  "m443": {
    "uz": "Server javobi: {0}",
    "ru": "Ответ сервера: {0}",
    "en": "Server response: {0}"
  },
  "m444": {
    "uz": "Server noma’lum holat qaytardi: {0}",
    "ru": "Сервер вернул неизвестный статус: {0}",
    "en": "Unknown server status: {0}"
  },
  "m445": {
    "uz":
        "Server sotuvni qabul qilgan bo‘lishi mumkin. Takroriy sotuv yaratishdan oldin sotuvlar tarixini tekshiring. Oynani yopasizmi?",
    "ru":
        "Сервер мог принять продажу. Проверьте историю продаж перед повтором. Закрыть окно?",
    "en":
        "The server may have accepted the sale. Check sales history before creating another sale. Close this window?"
  },
  "m446": {
    "uz": "Server xatosi: HTTP {0}.",
    "ru": "Ошибка сервера: HTTP {0}.",
    "en": "Server error: HTTP {0}."
  },
  "m447": {
    "uz":
        "Serverga ulanib bo‘lmadi. Internetni tekshirib qayta urinib ko‘ring.",
    "ru":
        "Не удалось подключиться к серверу. Проверьте интернет и повторите попытку.",
    "en": "Could not reach the server. Check your connection and try again."
  },
  "m448": {
    "uz": "Serverga ulanib bo‘lmadi. Internetni tekshiring.",
    "ru": "Не удалось подключиться к серверу. Проверьте интернет.",
    "en": "Could not reach the server. Check your connection."
  },
  "m449": {
    "uz": "Serverga ulanish amalga oshmadi.",
    "ru": "Не удалось подключиться к серверу.",
    "en": "Could not connect to the server."
  },
  "m450": {
    "uz": "Serverga ulanish yo‘q. Internetni tekshiring.",
    "ru": "Нет связи с сервером. Проверьте интернет.",
    "en": "No server connection. Check your internet."
  },
  "m451": {
    "uz": "Serverga ulanish yo‘q. Sotuvlar qurilmada saqlangan.",
    "ru": "Нет связи с сервером. Продажи сохранены на устройстве.",
    "en": "No server connection. Sales are saved on this device."
  },
  "m452": {
    "uz": "Sessiya muddati tugagan. Qayta tizimga kiring.",
    "ru": "Сессия истекла. Войдите снова.",
    "en": "Session expired. Sign in again."
  },
  "m453": {
    "uz": "Sessiyani yangilashda tarmoq uzildi.",
    "ru": "Сеть прервалась при обновлении сессии.",
    "en": "Connection lost while refreshing the session."
  },
  "m454": {
    "uz": "Shtrix kod skanerlash",
    "ru": "Сканировать штрихкод",
    "en": "Scan barcode"
  },
  "m455": {"uz": "Shtrix-kod", "ru": "Штрихкод", "en": "Barcode"},
  "m456": {
    "uz": "Shtrix-kod (USB skaner uchun)",
    "ru": "Штрихкод (USB-сканер)",
    "en": "Barcode (USB scanner)"
  },
  "m457": {
    "uz": "Shtrix-kodni skanerlang yoki mahsulotni qidiring...",
    "ru": "Сканируйте штрихкод или найдите товар…",
    "en": "Scan a barcode or search for a product…"
  },
  "m458": {
    "uz": "Shtrix-kodni skanerlash",
    "ru": "Сканировать штрихкод",
    "en": "Scan barcode"
  },
  "m459": {"uz": "Sinxronlash", "ru": "Синхронизировать", "en": "Sync"},
  "m460": {
    "uz": "Sinxronlash bajarilmadi. Sotuvlar o‘chirilmagan.",
    "ru": "Синхронизация не выполнена. Продажи сохранены.",
    "en": "Sync failed. Sales have not been deleted."
  },
  "m461": {
    "uz": "Sinxronlash hali davom etmoqda.",
    "ru": "Синхронизация ещё выполняется.",
    "en": "Sync is still running."
  },
  "m462": {
    "uz": "Sinxronlash javobida results ro‘yxati yo‘q.",
    "ru": "В ответе синхронизации нет списка results.",
    "en": "Sync response is missing the results list."
  },
  "m463": {
    "uz": "Sinxronlash tugagach bekor qiling.",
    "ru": "Дождитесь синхронизации перед отменой.",
    "en": "Wait for sync before cancelling."
  },
  "m464": {
    "uz": "Sinxronlash tugagach qayta urinib ko‘ring.",
    "ru": "Повторите после синхронизации.",
    "en": "Try again after sync completes."
  },
  "m465": {
    "uz": "Sinxronlash tugashini kuting.",
    "ru": "Дождитесь окончания синхронизации.",
    "en": "Wait for sync to finish."
  },
  "m466": {"uz": "Skanerlash", "ru": "Сканировать", "en": "Scan"},
  "m467": {
    "uz": "So'nggi sotuvlar",
    "ru": "Последние продажи",
    "en": "Recent sales"
  },
  "m469": {
    "uz": "Sotilgan miqdor: {0}",
    "ru": "Продано: {0}",
    "en": "Quantity sold: {0}"
  },
  "m470": {
    "uz": "Sotuv egasi va API akkaunti mos emas.",
    "ru": "Владелец продажи не совпадает с аккаунтом API.",
    "en": "The sale owner does not match the API account."
  },
  "m471": {"uz": "Sotuv narxi", "ru": "Цена продажи", "en": "Sale price"},
  "m472": {"uz": "Sotuv narxi *", "ru": "Цена продажи *", "en": "Sale price *"},
  "m473": {
    "uz": "Sotuv narxi xarid narxidan past",
    "ru": "Цена продажи ниже закупочной",
    "en": "Sale price is below purchase price"
  },
  "m474": {
    "uz": "Sotuv narxini kiriting",
    "ru": "Введите цену продажи",
    "en": "Enter sale price"
  },
  "m475": {
    "uz": "Sotuv natijasi noaniq",
    "ru": "Результат продажи неизвестен",
    "en": "Sale outcome unknown"
  },
  "m476": {
    "uz":
        "Sotuv natijasini aniqlab bo‘lmadi. Shu oynada qayta urining: operatsiya ID si saqlangan.",
    "ru":
        "Не удалось определить результат продажи. Повторите в этом окне: ID операции сохранён.",
    "en":
        "Could not confirm the sale outcome. Retry in this window; the operation ID is preserved."
  },
  "m477": {
    "uz":
        "Sotuv qurilmada saqlandi. Server tasdig‘i sinxronlashdan keyin olinadi.",
    "ru":
        "Продажа сохранена на устройстве. Подтверждение сервера будет получено после синхронизации.",
    "en":
        "Sale saved on this device. Server confirmation will follow after sync."
  },
  "m478": {
    "uz": "Sotuv saqlandi. Mahsulotlarni keyinroq yangilang.",
    "ru": "Продажа сохранена. Обновите товары позже.",
    "en": "Sale saved. Refresh products later."
  },
  "m479": {
    "uz": "Sotuv serverga yuborilganda qoldiq qayta tekshiriladi.",
    "ru": "При отправке продажи сервер повторно проверит остаток.",
    "en": "The server will recheck stock when the sale is submitted."
  },
  "m480": {
    "uz": "Sotuvdagi mahsulot yoki miqdor noto‘g‘ri.",
    "ru": "Некорректный товар или количество в продаже.",
    "en": "Invalid product or quantity in sale."
  },
  "m481": {
    "uz": "Sotuvlar tarixi",
    "ru": "История продаж",
    "en": "Sales history"
  },
  "m482": {"uz": "Sotuvlar yo'q", "ru": "Продаж нет", "en": "No sales"},
  "m483": {
    "uz":
        "Sotuvni qurilmaga saqlab bo‘lmadi. Savat saqlangan. Qayta urinib ko‘ring.",
    "ru":
        "Не удалось сохранить продажу на устройстве. Корзина сохранена. Попробуйте снова.",
    "en":
        "Could not save the sale on this device. Your cart is preserved. Try again."
  },
  "m484": {
    "uz": "Sotuvni tekshirish kerak.",
    "ru": "Нужно проверить продажу.",
    "en": "The sale needs review."
  },
  "m485": {
    "uz": "Sozlamalarni ochish",
    "ru": "Открыть настройки",
    "en": "Open settings"
  },
  "m486": {
    "uz": "So‘nggi muhim amallar",
    "ru": "Последние важные действия",
    "en": "Recent important actions"
  },
  "m487": {"uz": "Statistika", "ru": "Статистика", "en": "Statistics"},
  "m488": {"uz": "Summa", "ru": "Сумма", "en": "Amount"},
  "m489": {"uz": "Superadmin", "ru": "Суперадминистратор", "en": "Superadmin"},
  "m490": {"uz": "TO'LOV TURI", "ru": "СПОСОБ ОПЛАТЫ", "en": "PAYMENT METHOD"},
  "m491": {"uz": "TO'LOV:", "ru": "ОПЛАТА:", "en": "PAYMENT:"},
  "m492": {"uz": "TUGAGAN", "ru": "НЕТ В НАЛИЧИИ", "en": "OUT OF STOCK"},
  "m493": {"uz": "Tafsilotlar", "ru": "Подробнее", "en": "Details"},
  "m494": {
    "uz": "Tafsilotlarni yuklab bo‘lmadi",
    "ru": "Не удалось загрузить сведения",
    "en": "Could not load details"
  },
  "m495": {"uz": "Tahrirlash", "ru": "Редактировать", "en": "Edit"},
  "m496": {
    "uz": "Tarif holatini saqlab bo‘lmadi: {0}",
    "ru": "Не удалось сохранить статус тарифа: {0}",
    "en": "Could not save plan status: {0}"
  },
  "m497": {
    "uz": "Tarif ma’lumotlarini to‘g‘ri kiriting",
    "ru": "Проверьте сведения тарифа",
    "en": "Check plan details"
  },
  "m498": {"uz": "Tarif nomi", "ru": "Название тарифа", "en": "Plan name"},
  "m499": {
    "uz": "Tarif saqlanmadi: {0}",
    "ru": "Не удалось сохранить тариф: {0}",
    "en": "Could not save plan: {0}"
  },
  "m500": {
    "uz": "Tarif: {0} · Tugash sanasi: {1}",
    "ru": "Тариф: {0} · Действует до: {1}",
    "en": "Plan: {0} · Expires: {1}"
  },
  "m501": {"uz": "Tariflar", "ru": "Тарифы", "en": "Plans"},
  "m502": {
    "uz": "Tariflar mavjud emas",
    "ru": "Тарифов нет",
    "en": "No plans available"
  },
  "m503": {
    "uz": "Tarifni tahrirlash",
    "ru": "Редактировать тариф",
    "en": "Edit plan"
  },
  "m504": {
    "uz":
        "Tarifni tanlang va to‘lov arizasini yuboring. Obuna administrator to‘lovni tasdiqlagach faollashadi.",
    "ru":
        "Выберите тариф и отправьте заявку на оплату. Подписка активируется после подтверждения администратора.",
    "en":
        "Choose a plan and send a payment request. Your subscription activates after administrator approval."
  },
  "m505": {"uz": "Tarifni tanlash", "ru": "Выбрать тариф", "en": "Choose plan"},
  "m506": {
    "uz": "Tarifni uzaytirish",
    "ru": "Продлить тариф",
    "en": "Renew plan"
  },
  "m507": {
    "uz": "Tarifning bir to‘lov davri uchun",
    "ru": "За один платёжный период тарифа",
    "en": "Per plan billing period"
  },
  "m508": {"uz": "Tasdiqlangan", "ru": "Подтверждено", "en": "Approved"},
  "m509": {
    "uz": "Tasdiqlangan to‘lovlar",
    "ru": "Подтверждённые платежи",
    "en": "Approved payments"
  },
  "m510": {
    "uz":
        "Tasdiqlanmagan sotuvlar bor, mahsulot keshi yo‘q. Avval sotuvlarni sinxronlang.",
    "ru":
        "Есть неподтверждённые продажи, но кеш товаров отсутствует. Сначала синхронизируйте продажи.",
    "en": "There are unconfirmed sales but no product cache. Sync sales first."
  },
  "m511": {"uz": "Tasdiqlash", "ru": "Подтвердить", "en": "Confirm"},
  "m512": {"uz": "Tavsif", "ru": "Описание", "en": "Description"},
  "m513": {
    "uz": "Tekshirilgan vaqt",
    "ru": "Время проверки",
    "en": "Checked at"
  },
  "m514": {"uz": "Tekshirilmoqda...", "ru": "Проверка…", "en": "Checking…"},
  "m515": {
    "uz": "Tekshiruv sababi (majburiy)",
    "ru": "Причина проверки (обязательно)",
    "en": "Review reason (required)"
  },
  "m516": {
    "uz": "Telefon (ixtiyoriy)",
    "ru": "Телефон (необязательно)",
    "en": "Phone (optional)"
  },
  "m517": {"uz": "Telefon: {0}", "ru": "Телефон: {0}", "en": "Phone: {0}"},
  "m518": {
    "uz": "Tez amallar",
    "ru": "Быстрые действия",
    "en": "Quick actions"
  },
  "m519": {"uz": "Tez qo'shish", "ru": "Быстрое добавление", "en": "Quick add"},
  "m520": {"uz": "Tez tanlov", "ru": "Быстрый выбор", "en": "Quick selection"},
  "m521": {"uz": "Tizim", "ru": "Система", "en": "System"},
  "m522": {
    "uz": "Tizim boshqaruvi",
    "ru": "Управление системой",
    "en": "System management"
  },
  "m523": {
    "uz": "Tizim holati",
    "ru": "Состояние системы",
    "en": "System status"
  },
  "m524": {"uz": "Tizimga mos", "ru": "Как в системе", "en": "System default"},
  "m525": {
    "uz": "Tizimga yangi user qo'shish",
    "ru": "Добавить пользователя",
    "en": "Add a user"
  },
  "m526": {
    "uz": "Tizimni boshqarish va nazorat qilish",
    "ru": "Управление и мониторинг системы",
    "en": "Manage and monitor the system"
  },
  "m527": {
    "uz": "To'g'ri miqdor kiriting",
    "ru": "Введите корректное количество",
    "en": "Enter a valid quantity"
  },
  "m528": {
    "uz": "To'g'ri narx kiriting",
    "ru": "Введите корректную цену",
    "en": "Enter a valid price"
  },
  "m529": {
    "uz": "To'lov usullari",
    "ru": "Способы оплаты",
    "en": "Payment methods"
  },
  "m530": {
    "uz": "To'lovga o'tish",
    "ru": "Перейти к оплате",
    "en": "Proceed to payment"
  },
  "m531": {
    "uz": "To'lovga o'tish ({0})",
    "ru": "Перейти к оплате ({0})",
    "en": "Proceed to payment ({0})"
  },
  "m532": {
    "uz": "Top mahsulotlar",
    "ru": "Популярные товары",
    "en": "Top products"
  },
  "m533": {"uz": "Tozalash", "ru": "Очистить", "en": "Clear"},
  "m534": {"uz": "To‘langan", "ru": "Оплачено", "en": "Paid"},
  "m535": {"uz": "To‘langan: {0}", "ru": "Оплачено: {0}", "en": "Paid: {0}"},
  "m536": {"uz": "To‘lanmagan", "ru": "Не оплачено", "en": "Unpaid"},
  "m537": {"uz": "To‘liq", "ru": "Полностью", "en": "Full"},
  "m538": {
    "uz": "To‘liq to‘langan",
    "ru": "Оплачено полностью",
    "en": "Fully paid"
  },
  "m539": {"uz": "To‘lov", "ru": "Оплата", "en": "Payment"},
  "m540": {
    "uz": "To‘lov holati",
    "ru": "Статус оплаты",
    "en": "Payment status"
  },
  "m541": {
    "uz": "To‘lov izohi / tranzaksiya raqami",
    "ru": "Комментарий / номер транзакции",
    "en": "Payment note / transaction number"
  },
  "m542": {
    "uz": "To‘lov muddati",
    "ru": "Период оплаты",
    "en": "Billing period"
  },
  "m543": {
    "uz": "To‘lov muddatini tanlash",
    "ru": "Выбрать период оплаты",
    "en": "Choose a billing period"
  },
  "m544": {
    "uz": "To‘lov musbat bo‘lsin va qoldiqdan oshmasin",
    "ru": "Платёж должен быть больше нуля и не превышать остаток",
    "en": "Payment must be positive and must not exceed the balance"
  },
  "m545": {
    "uz": "To‘lov sanasi: {0}",
    "ru": "Дата оплаты: {0}",
    "en": "Payment date: {0}"
  },
  "m546": {
    "uz": "To‘lov saqlanmadi. Server javobini tekshiring.",
    "ru": "Платёж не сохранён. Проверьте ответ сервера.",
    "en": "Payment not saved. Check the server response."
  },
  "m547": {"uz": "To‘lov summasi", "ru": "Сумма к оплате", "en": "Amount due"},
  "m548": {"uz": "To‘lov turi", "ru": "Способ оплаты", "en": "Payment method"},
  "m549": {
    "uz": "To‘lov yetarli emas yoki karta summasi ortiqcha.",
    "ru": "Недостаточная оплата или сумма по карте превышает итог.",
    "en": "Insufficient payment or the card amount exceeds the total."
  },
  "m550": {"uz": "To‘lovlar", "ru": "Платежи", "en": "Payments"},
  "m551": {
    "uz": "To‘lovlar tarixi",
    "ru": "История платежей",
    "en": "Payment history"
  },
  "m552": {
    "uz": "To‘lovni tasdiqlab bo‘lmadi: {0}",
    "ru": "Не удалось подтвердить платёж: {0}",
    "en": "Could not approve payment: {0}"
  },
  "m553": {
    "uz": "To‘lovni tasdiqlash",
    "ru": "Подтвердить платёж",
    "en": "Approve payment"
  },
  "m554": {"uz": "Trial", "ru": "Пробный период", "en": "Trial"},
  "m555": {
    "uz": "Trial / muddati tugagan",
    "ru": "Пробный / истёкший",
    "en": "Trial / expired"
  },
  "m556": {
    "uz": "Trial kunlari",
    "ru": "Дней пробного периода",
    "en": "Trial days"
  },
  "m557": {"uz": "Tugagan", "ru": "Закончился", "en": "Expired"},
  "m558": {"uz": "Tugash sanasi", "ru": "Дата окончания", "en": "Expiry date"},
  "m559": {"uz": "Tushunarli", "ru": "Понятно", "en": "Got it"},
  "m560": {
    "uz": "Umumiy daromad",
    "ru": "Общая выручка",
    "en": "Total revenue"
  },
  "m561": {
    "uz": "User holatini o‘zgartirib bo‘lmadi: {0}",
    "ru": "Не удалось изменить статус пользователя: {0}",
    "en": "Could not update user status: {0}"
  },
  "m562": {
    "uz": "User limiti",
    "ru": "Лимит пользователей",
    "en": "User limit"
  },
  "m563": {"uz": "Userlar", "ru": "Пользователи", "en": "Users"},
  "m564": {"uz": "Username", "ru": "Имя пользователя", "en": "Username"},
  "m565": {
    "uz": "Username majburiy",
    "ru": "Имя пользователя обязательно",
    "en": "Username is required"
  },
  "m566": {
    "uz": "Username o‘zgartirildi",
    "ru": "Имя пользователя изменено",
    "en": "Username changed"
  },
  "m567": {
    "uz": "Username yoki do‘kon",
    "ru": "Имя пользователя или магазин",
    "en": "Username or store"
  },
  "m568": {
    "uz": "Username: {0}",
    "ru": "Имя пользователя: {0}",
    "en": "Username: {0}"
  },
  "m569": {
    "uz": "Username’ni o‘zgartirish",
    "ru": "Изменить имя пользователя",
    "en": "Change username"
  },
  "m570": {
    "uz": "Userni bloklash",
    "ru": "Заблокировать пользователя",
    "en": "Block user"
  },
  "m571": {
    "uz": "Userni faollashtirish",
    "ru": "Активировать пользователя",
    "en": "Activate user"
  },
  "m572": {
    "uz": "Uzaytirish muddati (oy)",
    "ru": "Продлить на (месяцы)",
    "en": "Extend by (months)"
  },
  "m574": {
    "uz": "Xarid narxi",
    "ru": "Закупочная цена",
    "en": "Purchase price"
  },
  "m575": {
    "uz": "Xatolik yuz berdi",
    "ru": "Произошла ошибка",
    "en": "Something went wrong"
  },
  "m576": {"uz": "Xatolik: {0}", "ru": "Ошибка: {0}", "en": "Error: {0}"},
  "m577": {
    "uz": "Xavfsizlik uchun parolingizni muntazam yangilang",
    "ru": "Регулярно обновляйте пароль для безопасности",
    "en": "Update your password regularly for security"
  },
  "m578": {
    "uz": "Xavfsizlik uchun parolingizni o'zgartirish shart",
    "ru": "Для безопасности необходимо изменить пароль",
    "en": "You must change your password for security"
  },
  "m579": {
    "uz": "Xavfsizlik uchun qayta kirish kerak bo'ladi",
    "ru": "Для безопасности потребуется повторный вход",
    "en": "You will need to sign in again for security"
  },
  "m580": {
    "uz": "Yangi foydalanuvchi",
    "ru": "Новый пользователь",
    "en": "New user"
  },
  "m581": {
    "uz": "Yangi mahsulot qo'shish",
    "ru": "Добавить новый товар",
    "en": "Add a new product"
  },
  "m582": {"uz": "Yangi parol", "ru": "Новый пароль", "en": "New password"},
  "m583": {
    "uz": "Yangi parol eski paroldan farqli bo'lishi kerak",
    "ru": "Новый пароль должен отличаться от старого",
    "en": "The new password must differ from the old password"
  },
  "m584": {
    "uz": "Yangi parol kamida 10 ta belgidan iborat bo'lishi kerak",
    "ru": "Новый пароль должен содержать не менее 10 символов",
    "en": "The new password must contain at least 10 characters"
  },
  "m585": {
    "uz": "Yangi parollar mos kelmadi",
    "ru": "Новые пароли не совпадают",
    "en": "New passwords do not match"
  },
  "m586": {
    "uz": "Yangi parolni kiriting",
    "ru": "Введите новый пароль",
    "en": "Enter a new password"
  },
  "m587": {
    "uz": "Yangi parolni tasdiqlang",
    "ru": "Подтвердите новый пароль",
    "en": "Confirm the new password"
  },
  "m588": {"uz": "Yangi qarz", "ru": "Новый долг", "en": "New debt"},
  "m589": {"uz": "Yangi qarzlar", "ru": "Новые долги", "en": "Newest debts"},
  "m590": {"uz": "Yangi qoldiq:", "ru": "Новый остаток:", "en": "New stock:"},
  "m591": {
    "uz": "Yangi surat olish",
    "ru": "Сделать снимок",
    "en": "Take a photo"
  },
  "m592": {"uz": "Yangi tarif", "ru": "Новый тариф", "en": "New plan"},
  "m593": {"uz": "Yangi user", "ru": "Новый пользователь", "en": "New user"},
  "m594": {
    "uz": "Yangi username",
    "ru": "Новое имя пользователя",
    "en": "New username"
  },
  "m595": {"uz": "Yangilash", "ru": "Обновить", "en": "Refresh"},
  "m596": {"uz": "Yaratilgan", "ru": "Создано", "en": "Created"},
  "m597": {"uz": "Yaratilmoqda...", "ru": "Создание…", "en": "Creating…"},
  "m598": {"uz": "Yaratish", "ru": "Создать", "en": "Create"},
  "m599": {
    "uz": "Yillik narx (so‘m)",
    "ru": "Годовая цена (сум)",
    "en": "Annual price (UZS)"
  },
  "m600": {"uz": "Yo'q", "ru": "Нет", "en": "No"},
  "m601": {"uz": "Yopish", "ru": "Закрыть", "en": "Close"},
  "m602": {"uz": "Yorug‘", "ru": "Светлая", "en": "Light"},
  "m603": {
    "uz": "Yuborilmagan sotuvlar yo‘q.",
    "ru": "Нет неотправленных продаж.",
    "en": "No unsent sales."
  },
  "m604": {"uz": "Yuborilmoqda...", "ru": "Отправка…", "en": "Sending…"},
  "m605": {"uz": "Yuklanmoqda...", "ru": "Загрузка…", "en": "Loading…"},
  "m620": {"uz": "mavjud emas", "ru": "недоступно", "en": "unavailable"},
  "m626": {"uz": "so‘m", "ru": "сум", "en": "UZS"},
  "m631": {"uz": "{0} UZS", "ru": "{0} UZS", "en": "{0} UZS"},
  "m632": {"uz": "{0} dona", "ru": "{0} шт.", "en": "{0} units"},
  "m633": {
    "uz": "{0} do‘koni holati o‘zgaradi.",
    "ru": "Изменится статус магазина {0}.",
    "en": "The status of store {0} will change."
  },
  "m634": {
    "uz": "{0} do‘koni uchun {1} {2} to‘lov obunani {3} muddatiga uzaytiradi.",
    "ru": "Платёж {1} {2} магазина {0} продлит подписку на {3}.",
    "en":
        "The {1} {2} payment for store {0} will extend its subscription by {3}."
  },
  "m635": {
    "uz": "{0} foydalanuvchi · {1} mahsulot",
    "ru": "{0} пользователей · {1} товаров",
    "en": "{0} users · {1} products"
  },
  "m636": {
    "uz": "{0} hisobi {1}.",
    "ru": "Аккаунт {0} {1}.",
    "en": "Account {0} is {1}."
  },
  "m637": {
    "uz": "{0} kam qoldi.",
    "ru": "Мало товара: {0}.",
    "en": "Low stock: {0}."
  },
  "m638": {"uz": "{0} mahsulot", "ru": "Товаров: {0}", "en": "{0} products"},
  "m639": {
    "uz": "{0} savatga qo'shildi",
    "ru": "{0} добавлен в корзину",
    "en": "{0} added to cart"
  },
  "m640": {
    "uz": "{0} savatga qo‘shildi",
    "ru": "{0} добавлен в корзину",
    "en": "{0} added to cart"
  },
  "m641": {"uz": "{0} so'm", "ru": "{0} сум", "en": "{0} UZS"},
  "m642": {"uz": "{0} so‘m", "ru": "{0} сум", "en": "{0} UZS"},
  "m643": {"uz": "{0} ta", "ru": "{0}", "en": "{0}"},
  "m644": {
    "uz": "{0} ta sotuv  •  o'rtacha {1} so'm",
    "ru": "Продаж: {0} • средний чек {1} сум",
    "en": "{0} sales • average {1} UZS"
  },
  "m645": {
    "uz": "{0} ta sotuv hali tasdiqlanmagan.",
    "ru": "Продаж без подтверждения: {0}.",
    "en": "{0} sales are still unconfirmed."
  },
  "m646": {
    "uz": "{0} ta sotuv serverda tasdiqlandi.",
    "ru": "Продаж подтверждено сервером: {0}.",
    "en": "{0} sales confirmed by the server."
  },
  "m647": {
    "uz": "{0} ta sotuv tekshirishni talab qiladi.",
    "ru": "Продаж для проверки: {0}.",
    "en": "{0} sales need review."
  },
  "m648": {
    "uz":
        "{0} ta tasdiqlanmagan sotuv bor. Ular shu akkaunt uchun qurilmada qoladi. Qayta kirish uchun internet kerak bo‘ladi. Chiqasizmi?",
    "ru":
        "Неподтверждённых продаж: {0}. Они останутся на устройстве для этого аккаунта. Для повторного входа нужен интернет. Выйти?",
    "en":
        "There are {0} unconfirmed sales. They will remain on this device for this account. Internet is required to sign in again. Sign out?"
  },
  "m649": {
    "uz": "{0} tugagan!",
    "ru": "{0} закончился!",
    "en": "{0} is out of stock!"
  },
  "m650": {
    "uz":
        "{0} {1}/oy · {2} {3}/yil\nUser {4} ta · mahsulot {5} ta · trial {6} kun",
    "ru":
        "{0} · {1}/мес. · {2} {3}/год\nПользователей: {4} · товаров: {5} · пробный период: {6} дней",
    "en":
        "{0} · {1}/month · {2} {3}/year\nUsers: {4} · products: {5} · trial: {6} days"
  },
  "m651": {"uz": "{0} · to‘lov", "ru": "{0} · платёж", "en": "{0} · payment"},
  "m652": {
    "uz": "{0} · {1} so‘m",
    "ru": "{0} · {1} сум",
    "en": "{0} · {1} UZS"
  },
  "m653": {"uz": "{0} · {1} ta", "ru": "{0} · {1}", "en": "{0} · {1}"},
  "m654": {
    "uz": "{0} · {1} · {2} · {3}\nTransaction: {4} · {5}",
    "ru": "{0} · {1} · {2} · {3}\nТранзакция: {4} · {5}",
    "en": "{0} · {1} · {2} · {3}\nTransaction: {4} · {5}"
  },
  "m655": {"uz": "{0} × {1}", "ru": "{0} × {1}", "en": "{0} × {1}"},
  "m656": {
    "uz": "{0}: omborda mahsulot qolmagan.",
    "ru": "{0}: товара нет на складе.",
    "en": "{0}: out of stock."
  },
  "m657": {
    "uz": "{0}: omborda yetarli mahsulot yo‘q.",
    "ru": "{0}: недостаточно товара на складе.",
    "en": "{0}: insufficient stock."
  },
  "m658": {"uz": "× {0}", "ru": "× {0}", "en": "× {0}"},
  "m659": {
    "uz": "• Eski paroldan farqli bo'lishi kerak",
    "ru": "• Отличается от старого пароля",
    "en": "• Must differ from the old password"
  },
  "m660": {
    "uz": "• Faqat raqamlardan iborat bo'lmasligi kerak",
    "ru": "• Не состоит только из цифр",
    "en": "• Must not contain only digits"
  },
  "m661": {
    "uz": "• Faqat raqamlardan iborat bo‘lmasligi kerak",
    "ru": "• Не состоит только из цифр",
    "en": "• Must not contain only digits"
  },
  "m662": {
    "uz": "• Kamida 10 ta belgi",
    "ru": "• Не менее 10 символов",
    "en": "• At least 10 characters"
  },
  "m663": {
    "uz": "• Umumiy parollardan foydalanmang",
    "ru": "• Не используйте распространённые пароли",
    "en": "• Do not use common passwords"
  },
  "language": {"uz": "Til", "ru": "Язык", "en": "Language"},
  "preferenceSaveError": {
    "uz": "Sozlama saqlanmadi. Qayta urinib ko‘ring.",
    "ru": "Не удалось сохранить настройку. Попробуйте снова.",
    "en": "Could not save the preference. Try again."
  },
  "sales": {"uz": "Savdo", "ru": "Продажи", "en": "Sales"},
  "plan": {"uz": "Tarif", "ru": "Тариф", "en": "Plan"},
  "unknown": {"uz": "noma’lum", "ru": "неизвестно", "en": "unknown"},
  "activationPending": {
    "uz": "Aktivatsiya kutilmoqda",
    "ru": "Ожидает активации",
    "en": "Awaiting activation"
  },
  "expiry": {
    "uz": " Tugash sanasi: {0}.",
    "ru": " Действует до: {0}.",
    "en": " Expires: {0}."
  },
  "added": {"uz": "qo'shildi", "ru": "добавлено", "en": "added"},
  "unitPiece": {"uz": "Dona", "ru": "Штука", "en": "Piece"},
  "unitPieceDesc": {
    "uz": "Sanoqli mahsulotlar",
    "ru": "Штучные товары",
    "en": "Counted items"
  },
  "unitPack": {"uz": "Pachka", "ru": "Пачка", "en": "Pack"},
  "unitPackDesc": {
    "uz": "Pachkada sotiladi",
    "ru": "Продажа пачками",
    "en": "Sold in packs"
  },
  "unitBottle": {"uz": "Butilka", "ru": "Бутылка", "en": "Bottle"},
  "unitBottleDesc": {
    "uz": "Butilkadagi ichimlik",
    "ru": "Напиток в бутылке",
    "en": "Bottled drink"
  },
  "unitGram": {"uz": "Gramm", "ru": "Грамм", "en": "Gram"},
  "weight": {"uz": "Og‘irlik", "ru": "Вес", "en": "Weight"},
  "volume": {"uz": "Hajm", "ru": "Объём", "en": "Volume"},
  "unitMl": {"uz": "Millilitr", "ru": "Миллилитр", "en": "Millilitre"},
  "unitKg": {
    "uz": "Kilogram (kg)",
    "ru": "Килограмм (кг)",
    "en": "Kilogram (kg)"
  },
  "unitLitre": {"uz": "Litr (l)", "ru": "Литр (л)", "en": "Litre (l)"},
  "unitMetre": {"uz": "Metr (m)", "ru": "Метр (м)", "en": "Metre (m)"},
  "length": {"uz": "Uzunlik", "ru": "Длина", "en": "Length"},
  "unitBox": {"uz": "Quti", "ru": "Коробка", "en": "Box"},
  "boxed": {"uz": "Qadoqlangan", "ru": "В коробках", "en": "Boxed"},
  "unitBag": {"uz": "Paket", "ru": "Пакет", "en": "Bag"},
  "bagged": {"uz": "Paketlangan", "ru": "В пакетах", "en": "Bagged"},
  "unitSquare": {
    "uz": "Kvadrat metr (m²)",
    "ru": "Квадратный метр (м²)",
    "en": "Square metre (m²)"
  },
  "area": {"uz": "Yuza", "ru": "Площадь", "en": "Area"},
  "unitCubic": {
    "uz": "Kub metr (m³)",
    "ru": "Кубический метр (м³)",
    "en": "Cubic metre (m³)"
  },
  "cameraSlow": {
    "uz": "Kamera javob bermayapti. Oynani yoping va qayta oching.",
    "ru": "Камера не отвечает. Закройте окно и откройте снова.",
    "en": "The camera is not responding. Close and reopen this window."
  },
  "cameraUnavailable": {
    "uz": "Kamerani ishga tushirib bo‘lmadi. Qayta urinib ko‘ring.",
    "ru": "Не удалось запустить камеру. Попробуйте снова.",
    "en": "Could not start the camera. Try again."
  },
  "pending": {"uz": "Kutilmoqda", "ru": "Ожидание", "en": "Pending"},
  "active": {"uz": "Faol", "ru": "Активна", "en": "Active"},
  "expired": {"uz": "Tugagan", "ru": "Истекла", "en": "Expired"},
  "cancelled": {"uz": "Bekor qilingan", "ru": "Отменена", "en": "Cancelled"},
  "rejected": {"uz": "Rad etilgan", "ru": "Отклонено", "en": "Rejected"},
  "approved": {"uz": "Tasdiqlangan", "ru": "Подтверждено", "en": "Approved"},
  "month": {"uz": "oy", "ru": "месяц", "en": "month"},
  "year": {"uz": "yil", "ru": "год", "en": "year"}
};
