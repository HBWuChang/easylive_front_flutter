#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Dart 文件 fontSize 批量修改工具
将所有 .dart 文件中的 fontSize: 数字, 修改为 fontSize: 数字.sp,

作者: AI Assistant
日期: 2025-06-22
"""

import os
import re
import argparse
from pathlib import Path
from typing import List, Tuple


class DartFontSizeProcessor:
    def __init__(self, root_dir: str, dry_run: bool = False):
        """
        初始化处理器
        
        Args:
            root_dir: 根目录路径
            dry_run: 是否为试运行模式（不实际修改文件）
        """
        self.root_dir = Path(root_dir)
        self.dry_run = dry_run
        self.pattern = re.compile(r'fontSize:\s*(\d+(?:\.\d+)?),')
        self.processed_files: List[str] = []
        self.modified_files: List[str] = []
        self.errors: List[Tuple[str, str]] = []
        
    def find_dart_files(self) -> List[Path]:
        """
        递归查找所有 .dart 文件
        
        Returns:
            List[Path]: 找到的 .dart 文件路径列表
        """
        dart_files = []
        try:
            for dart_file in self.root_dir.rglob("*.dart"):
                if dart_file.is_file():
                    dart_files.append(dart_file)
        except Exception as e:
            self.errors.append((str(self.root_dir), f"查找文件时出错: {e}"))
        
        return dart_files
    
    def process_file_content(self, content: str) -> Tuple[str, int]:
        """
        处理文件内容，替换 fontSize 属性
        
        Args:
            content: 原始文件内容
            
        Returns:
            Tuple[str, int]: (修改后的内容, 修改次数)
        """
        modified_content = content
        modification_count = 0
        
        def replace_fontsize(match):
            nonlocal modification_count
            font_size = match.group(1)
            modification_count += 1
            return f'fontSize: {font_size}.sp,'
        
        # 查找并替换所有匹配的 fontSize 属性
        # 只替换尚未添加 .sp 的情况
        pattern_without_sp = re.compile(r'fontSize:\s*(\d+(?:\.\d+)?),(?!\s*\.sp)')
        modified_content = pattern_without_sp.sub(replace_fontsize, content)
        
        return modified_content, modification_count
    
    def process_file(self, file_path: Path) -> bool:
        """
        处理单个文件
        
        Args:
            file_path: 文件路径
            
        Returns:
            bool: 是否成功处理
        """
        try:
            # 读取文件内容
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            # 处理内容
            modified_content, modification_count = self.process_file_content(original_content)
            
            self.processed_files.append(str(file_path))
            
            # 如果有修改
            if modification_count > 0:
                print(f"📝 {file_path.relative_to(self.root_dir)}: 找到 {modification_count} 处需要修改的 fontSize")
                
                if not self.dry_run:
                    # 写入修改后的内容
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(modified_content)
                    print(f"✅ 已修改 {file_path.relative_to(self.root_dir)}")
                else:
                    print(f"🔍 [试运行] 将修改 {file_path.relative_to(self.root_dir)}")
                
                self.modified_files.append(str(file_path))
                return True
            else:
                print(f"⏭️  {file_path.relative_to(self.root_dir)}: 无需修改")
                return True
                
        except Exception as e:
            error_msg = f"处理文件时出错: {e}"
            self.errors.append((str(file_path), error_msg))
            print(f"❌ {file_path.relative_to(self.root_dir)}: {error_msg}")
            return False
    
    def create_backup(self) -> bool:
        """
        创建备份（可选功能）
        
        Returns:
            bool: 是否成功创建备份
        """
        try:
            backup_dir = self.root_dir / "backup_before_fontsize_modification"
            if not backup_dir.exists():
                backup_dir.mkdir()
            
            print(f"📦 备份功能暂未实现，建议手动备份重要文件")
            return True
        except Exception as e:
            print(f"❌ 创建备份失败: {e}")
            return False
    
    def show_preview(self, file_path: Path, max_examples: int = 5) -> None:
        """
        显示文件修改预览
        
        Args:
            file_path: 文件路径
            max_examples: 最大显示示例数
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            lines = content.split('\n')
            examples = []
            
            for i, line in enumerate(lines):
                if self.pattern.search(line) and not line.strip().endswith('.sp,'):
                    original = line.strip()
                    modified = self.pattern.sub(r'fontSize: \1.sp,', line).strip()
                    examples.append((i + 1, original, modified))
                    
                    if len(examples) >= max_examples:
                        break
            
            if examples:
                print(f"\n📋 {file_path.relative_to(self.root_dir)} 预览修改:")
                for line_no, original, modified in examples:
                    print(f"  行 {line_no}:")
                    print(f"    - {original}")
                    print(f"    + {modified}")
                
                if len(examples) == max_examples:
                    print(f"    ... 还有更多修改项")
                print()
            
        except Exception as e:
            print(f"❌ 预览文件时出错: {e}")
    
    def process_all(self, show_preview: bool = False) -> None:
        """
        处理所有文件
        
        Args:
            show_preview: 是否显示预览
        """
        print(f"🔍 正在查找 {self.root_dir} 目录下的所有 .dart 文件...")
        dart_files = self.find_dart_files()
        
        if not dart_files:
            print("❌ 未找到任何 .dart 文件")
            return
        
        print(f"📁 找到 {len(dart_files)} 个 .dart 文件")
        
        if show_preview:
            print("\n🔍 预览模式 - 显示前几个需要修改的文件:")
            preview_count = 0
            for file_path in dart_files:
                if preview_count >= 3:  # 只预览前3个文件
                    break
                self.show_preview(file_path)
                if os.path.getsize(file_path) > 0:
                    preview_count += 1
        
        if self.dry_run:
            print("\n🧪 试运行模式 - 不会实际修改文件")
        else:
            print("\n🚀 开始处理文件...")
        
        print("-" * 60)
        
        # 处理每个文件
        for file_path in dart_files:
            self.process_file(file_path)
        
        # 显示处理结果
        self.show_summary()
    
    def show_summary(self) -> None:
        """显示处理结果摘要"""
        print("\n" + "=" * 60)
        print("📊 处理结果摘要")
        print("=" * 60)
        print(f"📁 总共处理文件: {len(self.processed_files)}")
        print(f"✅ 成功修改文件: {len(self.modified_files)}")
        print(f"❌ 处理出错文件: {len(self.errors)}")
        
        if self.modified_files:
            print(f"\n📝 已修改的文件:")
            for file_path in self.modified_files:
                rel_path = Path(file_path).relative_to(self.root_dir)
                print(f"  - {rel_path}")
        
        if self.errors:
            print(f"\n❌ 出错的文件:")
            for file_path, error in self.errors:
                rel_path = Path(file_path).relative_to(self.root_dir)
                print(f"  - {rel_path}: {error}")
        
        if self.dry_run:
            print(f"\n🧪 这是试运行结果，实际文件未被修改")
            print(f"💡 要执行实际修改，请移除 --dry-run 参数")
        else:
            print(f"\n✅ 处理完成！")
            if self.modified_files:
                print(f"💡 建议使用 Git 检查修改内容，确保无误后提交")


def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description="批量修改 Dart 文件中的 fontSize 属性，添加 .sp 后缀",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例用法:
  python add_sp_to_fontsize.py                          # 处理当前目录
  python add_sp_to_fontsize.py /path/to/flutter/project # 处理指定目录
  python add_sp_to_fontsize.py --dry-run                # 试运行模式
  python add_sp_to_fontsize.py --preview                # 显示预览
  python add_sp_to_fontsize.py --dry-run --preview      # 试运行+预览

注意事项:
  - 建议在运行前备份项目文件
  - 程序只会修改 fontSize: 数字, 格式的代码
  - 已经添加了 .sp 的代码不会被重复修改
        """
    )
    
    parser.add_argument(
        'directory',
        nargs='?',
        default='.',
        help='要处理的目录路径（默认为当前目录）'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='试运行模式，只显示将要修改的内容，不实际修改文件'
    )
    
    parser.add_argument(
        '--preview',
        action='store_true',
        help='显示修改预览'
    )
    
    args = parser.parse_args()
    
    # 检查目录是否存在
    target_dir = Path(args.directory).resolve()
    if not target_dir.exists():
        print(f"❌ 错误: 目录 '{target_dir}' 不存在")
        return 1
    
    if not target_dir.is_dir():
        print(f"❌ 错误: '{target_dir}' 不是一个目录")
        return 1
    
    print("🎯 Dart fontSize 批量修改工具")
    print(f"📂 目标目录: {target_dir}")
    print(f"🔧 模式: {'试运行' if args.dry_run else '实际修改'}")
    
    # 创建处理器并开始处理
    processor = DartFontSizeProcessor(str(target_dir), dry_run=args.dry_run)
    processor.process_all(show_preview=args.preview)
    
    return 0


if __name__ == '__main__':
    exit(main())
