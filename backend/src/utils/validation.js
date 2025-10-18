const Joi = require('joi');

// 用戶註冊驗證
const registerSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': '請輸入有效的電子郵件地址',
      'any.required': '電子郵件為必填項目'
    }),
  password: Joi.string()
    .min(6)
    .max(50)
    .required()
    .messages({
      'string.min': '密碼至少需要6個字符',
      'string.max': '密碼不能超過50個字符',
      'any.required': '密碼為必填項目'
    }),
  nickname: Joi.string()
    .min(2)
    .max(20)
    .required()
    .messages({
      'string.min': '暱稱至少需要2個字符',
      'string.max': '暱稱不能超過20個字符',
      'any.required': '暱稱為必填項目'
    }),
  realName: Joi.string()
    .min(2)
    .max(50)
    .required()
    .messages({
      'string.min': '真實姓名至少需要2個字符',
      'string.max': '真實姓名不能超過50個字符',
      'any.required': '真實姓名為必填項目'
    }),
  idCardNumber: Joi.string()
    .pattern(/^[A-Z][12]\d{8}$/)
    .required()
    .messages({
      'string.pattern.base': '請輸入有效的台灣身份證號碼',
      'any.required': '身份證號碼為必填項目'
    })
});

// 用戶登入驗證
const loginSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': '請輸入有效的電子郵件地址',
      'any.required': '電子郵件為必填項目'
    }),
  password: Joi.string()
    .required()
    .messages({
      'any.required': '密碼為必填項目'
    })
});

// 文章創建驗證
const createPostSchema = Joi.object({
  title: Joi.string()
    .min(1)
    .max(100)
    .required()
    .messages({
      'string.min': '標題不能為空',
      'string.max': '標題不能超過100個字符',
      'any.required': '標題為必填項目'
    }),
  content: Joi.string()
    .min(1)
    .max(5000)
    .required()
    .messages({
      'string.min': '內容不能為空',
      'string.max': '內容不能超過5000個字符',
      'any.required': '內容為必填項目'
    }),
  category: Joi.string()
    .valid('飲食', '穿著', '居住', '交通', '教育', '娛樂')
    .required()
    .messages({
      'any.only': '請選擇有效的分類',
      'any.required': '分類為必填項目'
    }),
  mainTab: Joi.string()
    .valid('共享', '共同', '熱門', '分享', '交換')
    .required()
    .messages({
      'any.only': '請選擇有效的標籤',
      'any.required': '標籤為必填項目'
    }),
  type: Joi.string()
    .valid('二手', '食譜', '遊記', '教學', '指南', '地圖', '知識', '路線', '交換')
    .required()
    .messages({
      'any.only': '請選擇有效的類型',
      'any.required': '類型為必填項目'
    }),
  city: Joi.string()
    .min(1)
    .max(50)
    .required()
    .messages({
      'string.min': '城市不能為空',
      'string.max': '城市名稱不能超過50個字符',
      'any.required': '城市為必填項目'
    }),
  tags: Joi.array()
    .items(Joi.string().max(20))
    .max(10)
    .optional()
    .messages({
      'array.max': '標籤數量不能超過10個',
      'string.max': '每個標籤不能超過20個字符'
    }),
  images: Joi.array()
    .items(Joi.string())
    .max(9)
    .optional()
    .messages({
      'array.max': '圖片數量不能超過9張'
    }),
  videos: Joi.array()
    .items(Joi.string())
    .max(3)
    .optional()
    .messages({
      'array.max': '視頻數量不能超過3個'
    })
});

// 用戶資料更新驗證
const updateProfileSchema = Joi.object({
  nickname: Joi.string()
    .min(2)
    .max(20)
    .optional()
    .messages({
      'string.min': '暱稱至少需要2個字符',
      'string.max': '暱稱不能超過20個字符'
    }),
  phone: Joi.string()
    .pattern(/^09\d{8}$/)
    .optional()
    .messages({
      'string.pattern.base': '請輸入有效的手機號碼'
    }),
  location: Joi.string()
    .max(100)
    .optional()
    .messages({
      'string.max': '所在地不能超過100個字符'
    })
});

// 評論驗證
const commentSchema = Joi.object({
  content: Joi.string()
    .min(1)
    .max(1000)
    .required()
    .messages({
      'string.min': '評論內容不能為空',
      'string.max': '評論內容不能超過1000個字符',
      'any.required': '評論內容為必填項目'
    })
});

// 搜索驗證
const searchSchema = Joi.object({
  query: Joi.string()
    .min(1)
    .max(100)
    .required()
    .messages({
      'string.min': '搜索關鍵字不能為空',
      'string.max': '搜索關鍵字不能超過100個字符',
      'any.required': '搜索關鍵字為必填項目'
    }),
  category: Joi.string()
    .valid('飲食', '穿著', '居住', '交通', '教育', '娛樂')
    .optional(),
  mainTab: Joi.string()
    .valid('共享', '共同', '熱門', '分享', '交換')
    .optional(),
  city: Joi.string()
    .max(50)
    .optional(),
  page: Joi.number()
    .integer()
    .min(1)
    .default(1)
    .optional(),
  limit: Joi.number()
    .integer()
    .min(1)
    .max(100)
    .default(20)
    .optional()
});

// 驗證中間件
const validate = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, { 
      abortEarly: false,
      stripUnknown: true 
    });
    
    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));
      
      return res.status(400).json({
        error: '數據驗證失敗',
        details: errors
      });
    }
    
    req.body = value;
    next();
  };
};

// 查詢參數驗證中間件
const validateQuery = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.query, { 
      abortEarly: false,
      stripUnknown: true 
    });
    
    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));
      
      return res.status(400).json({
        error: '查詢參數驗證失敗',
        details: errors
      });
    }
    
    req.query = value;
    next();
  };
};

module.exports = {
  registerSchema,
  loginSchema,
  createPostSchema,
  updateProfileSchema,
  commentSchema,
  searchSchema,
  validate,
  validateQuery
};



