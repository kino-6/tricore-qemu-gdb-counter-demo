# クロス設定は外出し（再現性◎）
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
# 事実上ここが実体
set(CMAKE_C_COMPILER /opt/bin/tricore-elf-gcc)
# 必要ならアセンブラも指定
# set(CMAKE_ASM_COMPILER /opt/bin/tricore-elf-as)
