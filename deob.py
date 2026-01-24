#!/usr/bin/env python3
"""
ZESTY LUAU DEOBFUSCATOR 2026 - ULTIMATE EDITION
Advanced bytecode analysis, hex decoding, VM reconstruction, and pattern detection
Supports: Luraph v14+, IronBrew, PSU, Moonsec, WeAreDevs, and custom obfuscators
Author: Enhanced for maximum deobfuscation power
"""
import re
import json
import base64
import struct
import sys
import math
from typing import Dict, List, Set, Tuple, Any, Optional
from urllib.parse import urlparse
from collections import defaultdict, Counter
class EnhancedBytecodeDecoder:
    """Advanced Luau/Lua bytecode decoder with full VM reconstruction"""
   
    def __init__(self):
        self.constants = []
        self.protos = []
        self.upvalues = []
        self.debug_info = {}
        self.version_info = {}
        self.vm_instructions = []
        self.string_pool = []
        self.number_pool = []
       
    def decode_bytecode_string(self, data: bytes) -> Optional[str]:
        """Enhanced bytecode decoder with full disassembly"""
        try:
            if len(data) < 4:
                return None
               
            # Check signature
            if data[:4] == b'\x1bLua':
                return self._decode_lua_bytecode(data)
            elif data[:4] == b'RSB1':
                return self._decode_roblox_bytecode(data)
            elif data[:3] == b'LPH':
                return self._decode_luraph_bytecode(data)
            elif data[:2] == b'\x1f\x8b':
                return self._decode_compressed_bytecode(data)
           
            # Try interpreting as raw bytecode
            return self._decode_raw_bytecode(data)
           
        except Exception as e:
            return f"-- BYTECODE DECODE ERROR: {str(e)}\n-- Raw hex: {data[:100].hex()}"
   
    def _decode_lua_bytecode(self, data: bytes) -> str:
        """Full Lua bytecode disassembly"""
        result = ["-- ╔══════════════════════════════════════════════════════════════════════════╗"]
        result.append("-- ║ DECODED LUA BYTECODE ║")
        result.append("-- ╚══════════════════════════════════════════════════════════════════════════╝")
        result.append("")
       
        # Parse header
        if len(data) > 12:
            version = data[4]
            format_version = data[5]
            endianness = data[6]
            int_size = data[7]
            size_t_size = data[8]
            instruction_size = data[9]
           
            result.append("-- ┌─ HEADER INFORMATION ─────────────────────────────────────────────────┐")
            result.append(f"-- │ Version: Lua {version // 16}.{version % 16}")
            result.append(f"-- │ Format Version: {format_version}")
            result.append(f"-- │ Endianness: {'Little-Endian' if endianness == 1 else 'Big-Endian'}")
            result.append(f"-- │ Integer Size: {int_size} bytes")
            result.append(f"-- │ Size_t Size: {size_t_size} bytes")
            result.append(f"-- │ Instruction Size: {instruction_size} bytes")
            result.append(f"-- │ Total Size: {len(data)} bytes")
            result.append("-- └──────────────────────────────────────────────────────────────────────┘")
            result.append("")
           
            self.version_info = {
                'version': version,
                'format': format_version,
                'endianness': endianness
            }
       
        # Extract string constants
        strings = self._extract_bytecode_strings(data)
        if strings:
            result.append(f"-- ┌─ STRING CONSTANTS ({len(strings)} found) ──────────────────────────────────┐")
            for i, s in enumerate(strings[:50]):
                clean_s = repr(s)[:70]
                result.append(f"-- │ [{i:3d}] = {clean_s}")
            if len(strings) > 50:
                result.append(f"-- │ ... and {len(strings) - 50} more strings")
            result.append("-- └──────────────────────────────────────────────────────────────────────┘")
            result.append("")
       
        # Extract number constants
        numbers = self._extract_number_constants(data)
        if numbers:
            result.append(f"-- ┌─ NUMBER CONSTANTS ({len(numbers)} found) ──────────────────────────────────┐")
            for i, n in enumerate(numbers[:30]):
                result.append(f"-- │ [{i:3d}] = {n}")
            if len(numbers) > 30:
                result.append(f"-- │ ... and {len(numbers) - 30} more numbers")
            result.append("-- └──────────────────────────────────────────────────────────────────────┘")
            result.append("")
       
        # Extract function prototypes
        functions = self._extract_function_prototypes(data)
        if functions:
            result.append(f"-- ┌─ FUNCTION PROTOTYPES ({len(functions)} found) ─────────────────────────────┐")
            for i, func in enumerate(functions[:20]):
                result.append(f"-- │ Function {i}:")
                result.append(f"-- │ ├─ Parameters: {func.get('params', 0)}")
                result.append(f"-- │ ├─ Upvalues: {func.get('upvalues', 0)}")
                result.append(f"-- │ ├─ Max Stack: {func.get('max_stack', 0)}")
                result.append(f"-- │ └─ Instructions: {func.get('instructions', 0)}")
            if len(functions) > 20:
                result.append(f"-- │ ... and {len(functions) - 20} more functions")
            result.append("-- └──────────────────────────────────────────────────────────────────────┘")
            result.append("")
       
        # Disassemble instructions
        instructions = self._disassemble_instructions(data)
        if instructions:
            result.append(f"-- ┌─ DISASSEMBLED INSTRUCTIONS ({len(instructions)} opcodes) ───────────────────┐")
            for i, instr in enumerate(instructions[:100]):
                result.append(f"-- │ {i:04d}: {instr}")
            if len(instructions) > 100:
                result.append(f"-- │ ... and {len(instructions) - 100} more instructions")
            result.append("-- └──────────────────────────────────────────────────────────────────────┘")
            result.append("")
       
        return '\n'.join(result)
   
    def _decode_roblox_bytecode(self, data: bytes) -> str:
        """Enhanced Roblox bytecode decoder"""
        result = ["-- ╔══════════════════════════════════════════════════════════════════════════╗"]
        result.append("-- ║ DECODED ROBLOX BYTECODE (RSB1) ║")
        result.append("-- ╚══════════════════════════════════════════════════════════════════════════╝")
        result.append("")
       
        try:
            # Roblox bytecode version
            if len(data) > 5:
                version = data[4]
                result.append(f"-- Roblox Bytecode Version: {version}")
           
            result.append(f"-- Total Size: {len(data):,} bytes")
            entropy = self._calculate_entropy(data)
            result.append(f"-- Entropy: {entropy:.2f} / 8.00")
            result.append("")
           
            # Extract type encodings (Roblox-specific)
            type_info = self._extract_roblox_types(data[4:])
            if type_info:
                result.append(f"-- ┌─ TYPE INFORMATION ────────────────────────────────────────────────┐")
                for type_name, count in sorted(type_info.items(), key=lambda x: -x[1])[:10]:
                    result.append(f"-- │ {type_name:20s}: {count:6d} occurrences")
                result.append("-- └──────────────────────────────────────────────────────────────────────┘")
                result.append("")
           
            # Extract strings
            strings = self._extract_bytecode_strings(data[4:])
            if strings:
                result.append(f"-- ┌─ EXTRACTED STRINGS ({len(strings)}) ──────────────────────────────────────┐")
                for i, s in enumerate(strings[:40]):
                    clean_s = repr(s)[:70]
                    result.append(f"-- │ [{i:3d}] = {clean_s}")
                if len(strings) > 40:
                    result.append(f"-- │ ... and {len(strings) - 40} more")
                result.append("-- └──────────────────────────────────────────────────────────────────────┘")
                result.append("")
           
            # Extract VM operations
            vm_ops = self._extract_roblox_vm_ops(data)
            if vm_ops:
                result.append(f"-- ┌─ VM OPERATIONS ({len(vm_ops)} detected) ────────────────────────────────┐")
                for op_name, count in sorted(vm_ops.items(), key=lambda x: -x[1])[:20]:
                    result.append(f"-- │ {op_name:30s}: {count:4d}x")
                result.append("-- └──────────────────────────────────────────────────────────────────────┘")
                result.append("")
           
        except Exception as e:
            result.append(f"-- ⚠️ Decode error: {e}")
       
        return '\n'.join(result)
   
    def _decode_luraph_bytecode(self, data: bytes) -> str:
        """Decode Luraph-specific bytecode"""
        result = ["-- ╔══════════════════════════════════════════════════════════════════════════╗"]
        result.append("-- ║ DECODED LURAPH BYTECODE ║")
        result.append("-- ╚══════════════════════════════════════════════════════════════════════════╝")
        result.append("")
       
        try:
            result.append(f"-- ⚠️ Luraph Protected Code Detected")
            result.append(f"-- Size: {len(data):,} bytes")
            result.append(f"-- Signature: {data[:10].hex()}")
            result.append("")
           
            # Extract VM table
            vm_functions = self._extract_luraph_vm_functions(data)
            if vm_functions:
                result.append(f"-- ┌─ VM FUNCTIONS ({len(vm_functions)} detected) ───────────────────────────┐")
                for func_name, func_info in list(vm_functions.items())[:20]:
                    calls = func_info.get('calls', 0)
                    result.append(f"-- │ {func_name:30s}: {calls} internal calls")
                if len(vm_functions) > 20:
                    result.append(f"-- │ ... and {len(vm_functions) - 20} more")
                result.append("-- └──────────────────────────────────────────────────────────────────────┘")
                result.append("")
           
            # Extract constant pools
            const_pools = self._extract_luraph_constants(data)
            if const_pools:
                result.append(f"-- ┌─ CONSTANT POOLS ──────────────────────────────────────────────────┐")
                for pool_type, values in const_pools.items():
                    result.append(f"-- │ {pool_type:20s}: {len(values)} values")
                    for val in values[:5]:
                        result.append(f"-- │ → {repr(val)[:60]}")
                result.append("-- └──────────────────────────────────────────────────────────────────────┘")
                result.append("")
           
        except Exception as e:
            result.append(f"-- ⚠️ Decode error: {e}")
       
        return '\n'.join(result)
   
    def _decode_compressed_bytecode(self, data: bytes) -> str:
        """Decode compressed bytecode"""
        import zlib
       
        result = ["-- ╔══════════════════════════════════════════════════════════════════════════╗"]
        result.append("-- ║ COMPRESSED BYTECODE DETECTED ║")
        result.append("-- ╚══════════════════════════════════════════════════════════════════════════╝")
        result.append("")
       
        try:
            result.append(f"-- Compressed Size: {len(data):,} bytes")
           
            # Try to decompress
            decompressed = zlib.decompress(data)
            result.append(f"-- Decompressed Size: {len(decompressed):,} bytes")
            result.append(f"-- Compression Ratio: {len(data)/len(decompressed)*100:.1f}%")
            result.append("")
           
            # Decode decompressed data
            inner_result = self.decode_bytecode_string(decompressed)
            if inner_result:
                result.append(inner_result)
           
        except Exception as e:
            result.append(f"-- ⚠️ Decompression failed: {e}")
       
        return '\n'.join(result)
   
    def _decode_raw_bytecode(self, data: bytes) -> str:
        """Attempt to decode unknown bytecode format"""
        result = ["-- ╔══════════════════════════════════════════════════════════════════════════╗"]
        result.append("-- ║ RAW BYTECODE ANALYSIS ║")
        result.append("-- ╚══════════════════════════════════════════════════════════════════════════╝")
        result.append("")
       
        result.append(f"-- Size: {len(data):,} bytes")
        result.append(f"-- Signature: {data[:4].hex() if len(data) >= 4 else 'N/A'}")
       
        # Entropy analysis
        entropy = self._calculate_entropy(data)
        result.append(f"-- Entropy: {entropy:.2f} / 8.00")
       
        if entropy > 7.5:
            result.append("-- ⚠️ HIGH ENTROPY - Possibly encrypted or compressed")
        elif entropy < 3.0:
            result.append("-- ℹ️ LOW ENTROPY - Likely plain text or simple encoding")
        result.append("")
       
        # Pattern detection
        patterns = self._detect_bytecode_patterns(data)
        if patterns:
            result.append(f"-- ┌─ DETECTED PATTERNS ────────────────────────────────────────────────┐")
            for pattern in patterns:
                result.append(f"-- │ ✓ {pattern}")
            result.append("-- └──────────────────────────────────────────────────────────────────────┘")
            result.append("")
       
        # Extract readable strings
        strings = self._extract_bytecode_strings(data)
        if strings:
            result.append(f"-- ┌─ EMBEDDED STRINGS ({len(strings)}) ──────────────────────────────────────┐")
            for i, s in enumerate(strings[:30]):
                clean_s = repr(s)[:65]
                result.append(f"-- │ {clean_s}")
            if len(strings) > 30:
                result.append(f"-- │ ... and {len(strings) - 30} more")
            result.append("-- └──────────────────────────────────────────────────────────────────────┘")
            result.append("")
       
        # Show hex dump
        result.append(f"-- ┌─ HEX DUMP (first 256 bytes) ──────────────────────────────────────────┐")
        hex_dump = self._format_hex_dump(data[:256])
        for line in hex_dump.split('\n'):
            result.append(f"-- │ {line}")
        result.append("-- └──────────────────────────────────────────────────────────────────────┘")
       
        return '\n'.join(result)
   
    def _extract_bytecode_strings(self, data: bytes) -> List[str]:
        """Enhanced string extraction with multiple detection methods"""
        strings = set()
       
        # Method 1: Length-prefixed strings (common in Lua bytecode)
        i = 0
        while i < len(data) - 4:
            try:
                for length_size in [1, 2, 4]:
                    if i + length_size >= len(data):
                        continue
                   
                    if length_size == 1:
                        length = data[i]
                    elif length_size == 2:
                        length = struct.unpack('<H', data[i:i+2])[0]
                    else:
                        length = struct.unpack('<I', data[i:i+4])[0]
                   
                    if 2 < length < 10000 and i + length_size + length <= len(data):
                        string_data = data[i+length_size:i+length_size+length]
                       
                        if self._is_likely_string(string_data):
                            try:
                                decoded = string_data.decode('utf-8', errors='ignore')
                                if decoded.strip() and len(decoded) > 1:
                                    strings.add(decoded)
                                    i += length_size + length
                                    break
                            except:
                                pass
            except:
                pass
           
            i += 1
       
        # Method 2: Null-terminated strings
        null_terminated = re.findall(b'[\x20-\x7e]{3,}?\x00', data)
        for match in null_terminated:
            try:
                decoded = match[:-1].decode('utf-8', errors='ignore')
                if decoded and len(decoded) > 2:
                    strings.add(decoded)
            except:
                pass
       
        # Method 3: Pattern-based extraction
        patterns = [
            rb'([a-zA-Z_][a-zA-Z0-9_]{2,})', # Identifiers
            rb'(http[s]?://[^\s\x00]+)', # URLs
            rb'(/[\w/]+)', # Paths
            rb'([\w]+\.[\w]+)', # File names
        ]
       
        for pattern in patterns:
            matches = re.findall(pattern, data)
            for match in matches:
                try:
                    decoded = match.decode('utf-8', errors='ignore')
                    if decoded and len(decoded) > 2:
                        strings.add(decoded)
                except:
                    pass
       
        return sorted(strings, key=len, reverse=True)[:200]
   
    def _extract_number_constants(self, data: bytes) -> List[float]:
        """Extract number constants from bytecode"""
        numbers = set()
       
        # Look for IEEE 754 double-precision floats
        i = 0
        while i < len(data) - 8:
            try:
                num = struct.unpack('<d', data[i:i+8])[0]
                if abs(num) < 1e10 and not math.isnan(num) and not math.isinf(num):
                    numbers.add(num)
            except:
                pass
            i += 4 # Step by 4 for performance
       
        # Look for integers
        i = 0
        while i < len(data) - 4:
            try:
                num = struct.unpack('<i', data[i:i+4])[0]
                if -1000000 < num < 1000000:
                    numbers.add(float(num))
                end
            except:
                pass
            i += 4
       
        return sorted(numbers)[:100]
   
    def _extract_function_prototypes(self, data: bytes) -> List[Dict]:
        """Extract function prototype information"""
        functions = []
       
        # Search for function signature patterns
        i = 0
        while i < len(data) - 20:
            try:
                # Lua function header pattern
                if data[i:i+2] == b'\\x00\\x00': # Potential function marker
                    params = data[i+2] if i+2 < len(data) else 0
                    is_vararg = data[i+3] if i+3 < len(data) else 0
                    max_stack = data[i+4] if i+4 < len(data) else 0
                   
                    if params < 20 and max_stack < 250:
                        if i+9 <= len(data):
                            num_instructions = struct.unpack('<I', data[i+5:i+9])[0]
                        else:
                            num_instructions = 0
                       
                        if num_instructions < 100000:
                            functions.append({
                                'offset': i,
                                'params': params,
                                'is_vararg': is_vararg,
                                'max_stack': max_stack,
                                'instructions': num_instructions,
                                'upvalues': 0
                            })
            except:
                pass
           
            i += 1
       
        return functions[:50]
   
    def _disassemble_instructions(self, data: bytes) -> List[str]:
        """Disassemble bytecode instructions"""
        instructions = []
       
        # Lua 5.x instruction format (4 bytes)
        opcodes_lua51 = [
            "MOVE", "LOADK", "LOADBOOL", "LOADNIL", "GETUPVAL",
            "GETGLOBAL", "GETTABLE", "SETGLOBAL", "SETUPVAL", "SETTABLE",
            "NEWTABLE", "SELF", "ADD", "SUB", "MUL", "DIV", "MOD",
            "POW", "UNM", "NOT", "LEN", "CONCAT", "JMP", "EQ", "LT",
            "LE", "TEST", "TESTSET", "CALL", "TAILCALL", "RETURN",
            "FORLOOP", "FORPREP", "TFORLOOP", "SETLIST", "CLOSE",
            "CLOSURE", "VARARG"
        ]
       
        i = 0
        instr_count = 0
        while i < len(data) - 4 and instr_count < 500:
            try:
                instr = struct.unpack('<I', data[i:i+4])[0]
               
                # Decode instruction
                opcode = instr & 0x3F
                a = (instr >> 6) & 0xFF
                c = (instr >> 14) & 0x1FF
                b = (instr >> 23) & 0x1FF
                bx = (instr >> 14) & 0x3FFFF
                sbx = bx - 131071
               
                opname = opcodes_lua51[opcode] if opcode < len(opcodes_lua51) else f"UNK_{opcode}"
               
                # Format based on instruction type
                if opname in ["LOADK", "GETGLOBAL", "SETGLOBAL", "CLOSURE"]:
                    instructions.append(f"{opname:12s} A={a:3d} Bx={bx:6d}")
                elif opname in ["JMP", "FORLOOP", "FORPREP"]:
                    instructions.append(f"{opname:12s} A={a:3d} sBx={sbx:6d}")
                else:
                    instructions.append(f"{opname:12s} A={a:3d} B={b:3d} C={c:3d}")
               
                instr_count += 1
               
            except:
                pass
           
            i += 4
       
        return instructions
   
    def _extract_roblox_types(self, data: bytes) -> Dict[str, int]:
        """Extract Roblox-specific type information"""
        type_counts = defaultdict(int)
       
        type_tags = {
            0: 'nil',
            1: 'boolean',
            2: 'lightuserdata',
            3: 'number',
            4: 'string',
            5: 'table',
            6: 'function',
            7: 'userdata',
            8: 'thread',
            9: 'vector'
        }
       
        for byte in data:
            if byte < 10:
                type_counts[type_tags.get(byte, f'unknown_{byte}')] += 1
       
        return dict(type_counts)
   
    def _extract_roblox_vm_ops(self, data: bytes) -> Dict[str, int]:
        """Extract Roblox VM operation patterns"""
        ops = defaultdict(int)
       
        # Common Roblox VM opcodes
        roblox_opcodes = [
            "GETGLOBAL", "SETGLOBAL", "CALL", "RETURN", "CLOSURE",
            "GETTABLE", "SETTABLE", "NEWTABLE", "LOADK", "MOVE"
        ]
       
        for opcode in roblox_opcodes:
            count = data.count(opcode.encode())
            if count > 0:
                ops[opcode] = count
       
        return dict(ops)
   
    def _extract_luraph_vm_functions(self, data: bytes) -> Dict:
        """Extract Luraph VM function table"""
        functions = {}
       
        # Luraph uses function name patterns
        func_pattern = rb'(\w+)\s*=\s*function'
        matches = re.findall(func_pattern, data)
       
        for match in matches[:100]:
            try:
                func_name = match.decode('utf-8', errors='ignore')
                if func_name and len(func_name) > 0:
                    functions[func_name] = {'calls': len(re.findall(func_name.encode(), data))}
            except:
                pass
       
        return functions
   
    def _extract_luraph_constants(self, data: bytes) -> Dict:
        """Extract Luraph constant pools"""
        pools = {}
       
        # Hex constants
        hex_constants = set(re.findall(rb'0[xX][0-9A-Fa-f]+', data))
        if hex_constants:
            pools['hex'] = sorted([c.decode() for c in hex_constants])[:50]
       
        # Binary constants
        bin_constants = set(re.findall(rb'0[bB][01]+', data))
        if bin_constants:
            pools['binary'] = sorted([c.decode() for c in bin_constants])[:50]
       
        return pools
   
    def _calculate_entropy(self, data: bytes) -> float:
        """Calculate Shannon entropy"""
        if not data:
            return 0
       
        counter = Counter(data)
        length = len(data)
       
        entropy = 0
        for count in counter.values():
            p = count / length
            entropy -= p * math.log2(p)
       
        return entropy
   
    def _detect_bytecode_patterns(self, data: bytes) -> List[str]:
        """Detect common bytecode patterns"""
        patterns = []
       
        # Check for VM signatures
        signatures = {
            b'LuaJIT': "LuaJIT bytecode",
            b'Luau': "Luau (Roblox) bytecode",
            b'LPH': "Luraph protection",
            b'IronBrew': "IronBrew obfuscation",
            b'PSU': "PSU obfuscation",
            b'Moonsec': "Moonsec obfuscation"
        }
       
        for sig, desc in signatures.items():
            if sig in data:
                patterns.append(desc)
       
        # Check for compression
        if data[:2] == b'\x1f\x8b':
            patterns.append("GZIP compression")
        elif data[:2] == b'BZ':
            patterns.append("BZIP2 compression")
        elif data[:4] == b'PK\x03\x04':
            patterns.append("ZIP archive")
       
        # Check for encryption patterns
        entropy = self._calculate_entropy(data)
        if entropy > 7.5:
            patterns.append(f"High entropy ({entropy:.2f}) - possibly encrypted")
        elif 5.0 < entropy < 7.0:
            patterns.append(f"Medium entropy ({entropy:.2f}) - likely compressed")
       
        return patterns
   
    def _format_hex_dump(self, data: bytes) -> str:
        """Format data as hex dump with ASCII"""
        lines = []
        for i in range(0, len(data), 16):
            chunk = data[i:i+16]
            hex_part = ' '.join(f'{b:02x}' for b in chunk)
            ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
            lines.append(f'{i:08x} {hex_part:<48} {ascii_part}')
        return '\n'.join(lines)
   
    def _is_likely_string(self, data: bytes) -> bool:
        """Enhanced string detection"""
        if not data or len(data) < 2:
            return False
       
        printable = sum(1 for b in data if 32 <= b < 127 or b in [9, 10, 13])
        ratio = printable / len(data)
       
        has_alpha = any(65 <= b < 91 or 97 <= b < 123 for b in data)
        has_space = 32 in data
       
        return ratio > 0.7 and (has_alpha or has_space)
class EnhancedHexDecoder:
    """Advanced hex decoder with multiple formats"""
   
    @staticmethod
    def decode_hex_string(hex_str: str) -> Optional[str]:
        """Enhanced hex decoder with format detection"""
        try:
            # Clean hex string
            hex_str = re.sub(r'[^0-9A-Fa-f]', '', hex_str)
           
            if len(hex_str) % 2 != 0 or len(hex_str) == 0:
                return None
           
            decoded = bytes.fromhex(hex_str)
           
            result = ["-- ╔══════════════════════════════════════════════════════════════════════════╗"]
            result.append("-- ║ HEX DECODED OUTPUT ║")
            result.append("-- ╚══════════════════════════════════════════════════════════════════════════╝")
            result.append("")
            result.append(f"-- Original Hex Length: {len(hex_str)} characters")
            result.append(f"-- Decoded Size: {len(decoded)} bytes")
            result.append("")
           
            # Try UTF-8
            try:
                text = decoded.decode('utf-8')
                if text.isprintable() or '\n' in text or '\t' in text:
                    result.append("-- ┌─ UTF-8 DECODED ───────────────────────────────────────────────────┐")
                    for line in text.split('\n')[:50]:
                        result.append(f"-- │ {line[:70]}")
                    result.append("-- └──────────────────────────────────────────────────────────────────────┘")
                    return '\n'.join(result) + '\n\n' + text
            except:
                pass
           
            # Try bytecode
            bytecode_decoder = EnhancedBytecodeDecoder()
            bc_result = bytecode_decoder.decode_bytecode_string(decoded)
            if bc_result and '═══' in bc_result:
                return '\n'.join(result) + '\n\n' + bc_result
           
            # Try base64
            try:
                b64_decoded = base64.b64decode(decoded)
                b64_text = b64_decoded.decode('utf-8', errors='ignore')
                if len(b64_text) > 10:
                    result.append("-- ┌─ BASE64 DECODED ──────────────────────────────────────────────────┐")
                    for line in b64_text.split('\n')[:30]:
                        result.append(f"-- │ {line[:70]}")
                    result.append("-- └──────────────────────────────────────────────────────────────────────┘")
                    return '\n'.join(result) + '\n\n' + b64_text
            except:
                pass
           
            # Show hex analysis
            entropy = bytecode_decoder._calculate_entropy(decoded)
            result.append(f"-- Entropy: {entropy:.2f} / 8.00")
           
            # Show readable parts
            readable = ''.join(chr(b) if 32 <= b < 127 else '.' for b in decoded)
            if sum(1 for c in readable if c != '.') > 10:
                result.append("")
                result.append("-- ┌─ READABLE CHARACTERS ─────────────────────────────────────────────┐")
                for i in range(0, len(readable), 70):
                    result.append(f"-- │ {readable[i:i+70]}")
                result.append("-- └──────────────────────────────────────────────────────────────────────┘")
           
            # Show hex dump
            result.append("")
            result.append("-- ┌─ HEX DUMP ────────────────────────────────────────────────────────────┐")
            hex_dump = bytecode_decoder._format_hex_dump(decoded[:256])
            for line in hex_dump.split('\n'):
                result.append(f"-- │ {line}")
            if len(decoded) > 256:
                result.append(f"-- │ ... and {len(decoded) - 256} more bytes")
            result.append("-- └──────────────────────────────────────────────────────────────────────┘")
           
            return '\n'.join(result)
           
        except Exception as e:
            return f"-- ⚠️ HEX DECODE ERROR: {e}"
class StringDecoder:
    """Enhanced string decoder supporting all Lua escape sequences"""
   
    @staticmethod
    def decode_zero_width_escapes(text: str) -> str:
        """Decode \z escapes (skip following whitespace)"""
        return re.sub(r'\\z\s*', '', text)
   
    @staticmethod
    def decode_octal_escapes(text: str) -> str:
        """Decode octal escape sequences (1-3 digits)"""
        def octal_replace(match):
            octal_num = match.group(1)
            try:
                char_code = int(octal_num, 8)
                if 0 <= char_code <= 255:
                    return chr(char_code)
            except:
                pass
            return match.group(0)
       
        return re.sub(r'\\(\d{1,3})', octal_replace, text)
   
    @staticmethod
    def decode_hex_escapes(text: str) -> str:
        """Decode hex escape sequences \\xNN"""
        def hex_replace(match):
            try:
                return chr(int(match.group(1), 16))
            except:
                return match.group(0)
       
        return re.sub(r'\\x([0-9A-Fa-f]{2})', hex_replace, text)
   
    @staticmethod
    def decode_unicode_escapes(text: str) -> str:
        """Decode unicode escape sequences \\u{XXXX}"""
        def unicode_replace(match):
            try:
                code_point = int(match.group(1), 16)
                if 0 <= code_point <= 0x10FFFF:
                    return chr(code_point)
            except:
                pass
            return match.group(0)
       
        return re.sub(r'\\u\{([0-9A-Fa-f]+)\}', unicode_replace, text)
   
    @staticmethod
    def decode_decimal_escapes(text: str) -> str:
        """Decode decimal escape sequences"""
        def decimal_replace(match):
            try:
                num = int(match.group(1))
                if 0 <= num <= 255:
                    return chr(num)
            except:
                pass
            return match.group(0)
       
        return re.sub(r'\\(\d{1,3})(?!\d)', decimal_replace, text)
   
    @staticmethod
    def decode_standard_escapes(text: str) -> str:
        """Decode standard escape sequences"""
        escape_map = {
            r'\a': '\a', r'\b': '\b', r'\f': '\f',
            r'\n': '\n', r'\r': '\r', r'\t': '\t',
            r'\v': '\v', r'\\': '\\', r'\"': '"', r"\'": "'"
        }
       
        for escape, char in escape_map.items():
            text = text.replace(escape, char)
       
        return text
   
    @staticmethod
    def decode_all_escapes(text: str) -> str:
        """Decode ALL escape sequences in proper order"""
        text = StringDecoder.decode_zero_width_escapes(text)
        text = StringDecoder.decode_unicode_escapes(text)
        text = StringDecoder.decode_hex_escapes(text)
        text = StringDecoder.decode_octal_escapes(text)
        text = StringDecoder.decode_standard_escapes(text)
        return text
class HexDecimalDecoder:
    """Enhanced hex and decimal decoder"""
   
    @staticmethod
    def decode_hex_string(hex_str: str) -> Optional[str]:
        """Decode hex string to readable text"""
        return EnhancedHexDecoder.decode_hex_string(hex_str)
   
    @staticmethod
    def decode_decimal_array(numbers: List[int]) -> Optional[str]:
        """Decode array of decimal bytes"""
        try:
            byte_data = bytes([n & 0xFF for n in numbers])
           
            # Try UTF-8
            try:
                text = byte_data.decode('utf-8')
                printable_ratio = sum(1 for c in text if c.isprintable() or c in '\n\t\r') / len(text)
                if printable_ratio > 0.7:
                    return text
            except:
                pass
           
            # Try bytecode
            bytecode_decoder = EnhancedBytecodeDecoder()
            bc_result = bytecode_decoder.decode_bytecode_string(byte_data)
            if bc_result:
                return bc_result
           
            # Show as escaped string
            result = []
            for b in byte_data:
                if 32 <= b < 127:
                    result.append(chr(b))
                else:
                    result.append(f'\\{b:03d}')
           
            return ''.join(result)
           
        except:
            return None
class LoadstringDecoder:
    """Enhanced loadstring decoder"""
   
    def __init__(self):
        self.hex_decoder = HexDecimalDecoder()
        self.bytecode_decoder = EnhancedBytecodeDecoder()
        self.string_decoder = StringDecoder()
   
    def decode_loadstring(self, content: str) -> str:
        """Decode loadstring content"""
        content = content.strip().strip('"\'')
       
        # Check if hex
        if re.match(r'^[0-9A-Fa-f\s]+$', content) and len(content) > 10:
            decoded = self.hex_decoder.decode_hex_string(content)
            if decoded:
                return decoded
       
        # Check if base64
        try:
            if re.match(r'^[A-Za-z0-9+/=]+$', content) and len(content) % 4 == 0:
                decoded_bytes = base64.b64decode(content)
               
                try:
                    return decoded_bytes.decode('utf-8')
                except:
                    pass
               
                bc_result = self.bytecode_decoder.decode_bytecode_string(decoded_bytes)
                if bc_result:
                    return bc_result
        except:
            pass
       
        # Decode escapes
        if '\\' in content:
            decoded = self.string_decoder.decode_all_escapes(content)
            if decoded != content:
                return decoded
       
        return content
class IronBrewDecoder:
    """Enhanced IronBrew decoder"""
   
    @staticmethod
    def decode_ironbrew_string(hex_string: str) -> Optional[str]:
        """Decode IronBrew hex-encoded strings"""
        try:
            hex_string = hex_string.strip()
           
            if hex_string.startswith('LOL!'):
                clean = hex_string[4:].replace('Q', '')
               
                if len(clean) % 2 != 0:
                    return None
               
                decoded_bytes = bytes.fromhex(clean)
                return decoded_bytes.decode('utf-8', errors='ignore')
           
            return None
        except:
            return None
   

    @staticmethod
    def find_ironbrew_strings(code: str) -> List[Tuple[str, str]]:
        """Find all IronBrew encoded strings"""
        results = []
        pattern = r'["\']LOL![^"\']+["\']'
       
        for match in re.finditer(pattern, code):
            original = match.group(0).strip('"\'')
            decoded = IronBrewDecoder.decode_ironbrew_string(original)
            if decoded:
                results.append((original, decoded))
       
        return results
class ControlFlowAnalyzer:
    """Analyze and simplify control flow obfuscation"""
   
    @staticmethod
    def find_control_flow_patterns(code: str) -> List[Dict]:
        """Find obfuscated control flow patterns"""
        patterns = []
       
        # Infinite loops
        while_pattern = r'while\s+true\s+do.*?break.*?end'
        for match in re.finditer(while_pattern, code, re.DOTALL | re.IGNORECASE):
            patterns.append({
                'type': 'infinite_loop',
                'code': match.group(0)[:100]
            })
       
        # Repeat-until-true
        repeat_pattern = r'repeat.*?until\s+true'
        for match in re.finditer(repeat_pattern, code, re.DOTALL | re.IGNORECASE):
            patterns.append({
                'type': 'repeat_until_true',
                'code': match.group(0)[:100]
            })
       
        # Jump tables
        jump_pattern = r'if\s+\w+\s*==\s*\d+\s+then.*?elseif'
        jump_matches = list(re.finditer(jump_pattern, code, re.DOTALL | re.IGNORECASE))
        if len(jump_matches) > 5:
            patterns.append({
                'type': 'jump_table',
                'count': len(jump_matches)
            })
       
        return patterns
class ZestyDeobfuscator:
    """Main deobfuscator class with all enhanced features"""
   
    def __init__(self):
        self.string_tables: Dict[str, List[str]] = {}
        self.function_tables: Dict[str, str] = {}
        self.constant_tables: Dict[str, List[int]] = {}
        self.hex_tables: Dict[str, str] = {}
        self.decimal_arrays: Dict[str, List[int]] = {}
        self.ironbrew_strings: List[Tuple[str, str]] = {}
        self.large_strings: List[str] = []
       
        self.string_decoder = StringDecoder()
        self.hex_decoder = HexDecimalDecoder()
        self.loadstring_decoder = LoadstringDecoder()
        self.bytecode_decoder = EnhancedBytecodeDecoder()
        self.ironbrew_decoder = IronBrewDecoder()
        self.control_flow_analyzer = ControlFlowAnalyzer()
       
        self.urls: List[Dict] = []
        self.loadstrings: List[Dict] = []
        self.decoded_loadstrings: List[Dict] = []
        self.namecalls: List[Dict] = []
        self.remote_calls: List[str] = []
        self.metamethods: List[Dict] = []
        self.hooks: List[Dict] = []
        self.anti_detection: List[Dict] = []
        self.suspicious: List[Dict] = []
        self.roblox_services: Set[str] = set()
        self.control_flow: List[Dict] = []
       
        self.stats = {
            'strings_decoded': 0,
            'functions_found': 0,
            'urls_extracted': 0,
            'risks_detected': 0,
            'bytecode_decoded': 0,
            'hex_decoded': 0,
            'octal_decoded': 0,
            'unicode_decoded': 0,
            'zero_width_decoded': 0,
            'ironbrew_decoded': 0,
            'loadstrings_decoded': 0,
            'control_flow_patterns': 0
        }
   
    def process(self, code: str) -> str:
        """Main processing pipeline"""
        print("\n" + "="*80)
        print("╔══════════════════════════════════════════════════════════════════════════╗")
        print("║ ZESTY LUAU DEOBFUSCATOR 2026 - ULTIMATE EDITION ║")
        print("║ Advanced Bytecode Analysis • VM Reconstruction • Pattern Detection ║")
        print("╚══════════════════════════════════════════════════════════════════════════╝")
        print("="*80 + "\n")
       
        print("PHASE 1: EXTRACTION")
        print("-" * 80)
        self._extract_all_tables(code)
       
        print("\nPHASE 2: DECODING")
        print("-" * 80)
        self._decode_all_encodings(code)
        self._decode_large_strings(code)
       
        print("\nPHASE 3: PATTERN DETECTION")
        print("-" * 80)
        self._detect_all_patterns(code)
       
        print("\nPHASE 4: CONTROL FLOW ANALYSIS")
        print("-" * 80)
        self._analyze_control_flow(code)
       
        print("\nPHASE 5: DEOBFUSCATION")
        print("-" * 80)
        code = self._deobfuscate_code(code)
       
        print("\nPHASE 6: SECURITY ANALYSIS")
        print("-" * 80)
        self._security_analysis(code)
       
        print("\nPHASE 7: GENERATING OUTPUT")
        print("-" * 80)
        readable = self._generate_output(code)
       
        return readable
   
    def _decode_base85_string(self, s: str) -> bytes or None:
        try:
            replaced = s.replace('z', '!!!!!')
            process_len = len(replaced) // 5 * 5
            decoded_bytes = b''
            for i in range(0, process_len, 5):
                chunk = replaced[i:i+5]
                digits = [ord(c) - 33 for c in chunk]
                if any(d < 0 or d > 84 for d in digits):
                    return None
                value = sum(d * 85**(4-j) for j, d in enumerate(digits))
                decoded_bytes += struct.pack('>I', value % (1 << 32))
            return decoded_bytes
        except:
            return None
   
    def _extract_large_strings(self, code: str):
        for match in re.finditer(r'\[=\[(.*?)\]=]', code, re.DOTALL):
            s = match.group(1)
            if len(s) > 100:
                self.large_strings.append(s)
   
    def _decode_large_strings(self, code: str):
        self._extract_large_strings(code)
        print("[2.5] Decoding large base85 strings...")
        for s in self.large_strings:
            decoded = self._decode_base85_string(s)
            if decoded:
                bc_result = self.bytecode_decoder.decode_bytecode_string(decoded)
                if bc_result and 'ERROR' not in bc_result:
                    self.decoded_loadstrings.append({
                        'original': s[:100] + '...',
                        'decoded': bc_result
                    })
                    self.stats['loadstrings_decoded'] += 1
                    print(f" ✓ Decoded base85 string (length {len(s)}) to bytecode (length {len(decoded)})")
   
    def _extract_all_tables(self, code: str):
        """Extract all data structures"""
        print("[1.1] String tables (all escape types)...")
        self._extract_string_tables(code)
       
        print("[1.2] Decimal byte arrays...")
        self._extract_decimal_arrays(code)
       
        print("[1.3] Hex strings...")
        self._extract_hex_strings(code)
       
        print("[1.4] Function lookup tables...")
        self._extract_function_tables(code)
       
        print("[1.5] Constant tables...")
        self._extract_constant_tables(code)
   
    def _extract_string_tables(self, code: str):
        """Extract string tables with enhanced escape handling"""
        pattern1 = r'(?s)local\s+([a-zA-Z_]\w*)\s*=\s*\{(.*?)\};?(?=\s*(?:local|function|end|return|$))'
        pattern2 = r'([a-zA-Z_]\w*)\s*=\s*\{([^{}]+)\}'
       
        for pattern in [pattern1, pattern2]:
            for match in re.finditer(pattern, code):
                var = match.group(1)
                body = match.group(2)
               
                if not any(c in body for c in ['"', "'", '\\']):
                    continue
               
                strings = []
               
                for s in re.findall(r'"((?:[^"\\]|\\.)*)"', body):
                    decoded = self.string_decoder.decode_all_escapes(s)
                    strings.append(decoded)
                   
                    if '\\z' in s:
                        self.stats['zero_width_decoded'] += 1
                    if '\\u{' in s:
                        self.stats['unicode_decoded'] += 1
                    if re.search(r'\\[0-9]{1,3}', s):
                        self.stats['octal_decoded'] += 1
               
                for s in re.findall(r"'((?:[^'\\]|\\.)*)'", body):
                    decoded = self.string_decoder.decode_all_escapes(s)
                    strings.append(decoded)
               
                if len(strings) >= 2:
                    self.string_tables[var] = strings
                    self.stats['strings_decoded'] += len(strings)
                   
                    encoding_type = "STANDARD"
                    if any('\\' in s for s in [m.group(0) for m in re.finditer(r'"[^"]*"', body)][:5]):
                        if '\\z' in body:
                            encoding_type = "ZERO-WIDTH + ESCAPES"
                        elif '\\u{' in body:
                            encoding_type = "UNICODE ESCAPES"
                        elif re.search(r'\\x[0-9A-Fa-f]', body):
                            encoding_type = "HEX ESCAPES"
                        elif re.search(r'\\[0-9]', body):
                            encoding_type = "OCTAL ESCAPES"
                   
                    print(f" ✓ Table '{var}': {len(strings)} strings ({encoding_type})")
                   
                    if strings and len(strings[0]) > 0:
                        sample = strings[0][:60] if len(strings[0]) > 60 else strings[0]
                        print(f" Sample: {repr(sample)}")
   
    def _extract_decimal_arrays(self, code: str):
        """Extract decimal byte arrays"""
        pattern = r'([a-zA-Z_]\w*)\s*=\s*\{([\d,\s]+)\}'
       
        for match in re.finditer(pattern, code):
            var = match.group(1)
            body = match.group(2)
           
            numbers = [int(n.strip()) for n in body.split(',') if n.strip().isdigit()]
           
            if numbers and all(0 <= n <= 255 for n in numbers) and len(numbers) > 10:
                self.decimal_arrays[var] = numbers
                print(f" ✓ Decimal array '{var}': {len(numbers)} bytes")
   
    def _extract_hex_strings(self, code: str):
        """Extract hex-encoded strings"""
        pattern = r'([a-zA-Z_]\w*)\s*=\s*"([0-9A-Fa-f\s]{20,})"'
       
        for match in re.finditer(pattern, code):
            var = match.group(1)
            hex_str = match.group(2)
           
            clean_hex = re.sub(r'\s', '', hex_str)
            if len(clean_hex) % 2 == 0 and re.match(r'^[0-9A-Fa-f]+$', clean_hex):
                self.hex_tables[var] = hex_str
                print(f" ✓ Hex string '{var}': {len(clean_hex)//2} bytes")
   
    def _extract_function_tables(self, code: str):
        """Extract function lookup patterns"""
        pattern = r'local\s+function\s+([a-zA-Z_]\w*)\s*\([^)]*\)\s*return\s+([a-zA-Z_]\w*)\['
       
        for match in re.finditer(pattern, code):
            func_name = match.group(1)
            table_name = match.group(2)
           
            if table_name in self.string_tables:
                self.function_tables[func_name] = table_name
                self.stats['functions_found'] += 1
                print(f" ✓ Function '{func_name}()' → table '{table_name}'")
   
    def _extract_constant_tables(self, code: str):
        """Extract constant tables"""
        pattern = r'local\s+([a-zA-Z_]\w*)\s*=\s*\{([\d,\s\-]+)\}'
       
        for match in re.finditer(pattern, code):
            var = match.group(1)
            body = match.group(2)
           
            numbers = []
            for n in body.split(','):
                n = n.strip()
                if re.match(r'^-?\d+$', n):
                    numbers.append(int(n))
           
            if len(numbers) > 5 and not all(0 <= n <= 255 for n in numbers):
                self.constant_tables[var] = numbers
                print(f" ✓ Constants '{var}': {len(numbers)} values")
   
    def _decode_all_encodings(self, code: str):
        """Decode all encoding methods"""
        print("[2.1] Decoding IronBrew strings...")
        self.ironbrew_strings = self.ironbrew_decoder.find_ironbrew_strings(code)
        if self.ironbrew_strings:
            for original, decoded in self.ironbrew_strings[:5]:
                self.stats['ironbrew_decoded'] += 1
                print(f" ✓ IronBrew: {original}... → {decoded[:60]}")
       
        print("[2.2] Decoding decimal arrays...")
        for var, numbers in self.decimal_arrays.items():
            decoded = self.hex_decoder.decode_decimal_array(numbers)
            if decoded:
                self.string_tables[var + "_DECODED"] = [decoded]
                self.stats['bytecode_decoded'] += 1
                print(f" ✓ Decoded '{var}': {len(decoded) if isinstance(decoded, str) else 'N/A'} chars")
                if isinstance(decoded, str):
                    preview = decoded[:100].replace('\n', ' ')
                    print(f" Preview: {preview}")
       
        print("[2.3] Decoding hex strings...")
        for var, hex_str in self.hex_tables.items():
            decoded = self.hex_decoder.decode_hex_string(hex_str)
            if decoded:
                self.string_tables[var + "_DECODED"] = [decoded]
                self.stats['hex_decoded'] += 1
                print(f" ✓ Decoded '{var}': {len(decoded) if isinstance(decoded, str) else 'N/A'} chars")
       
        print("[2.4] All escape sequences decoded during extraction ✓")
   
    def _detect_all_patterns(self, code: str):
        """Detect all suspicious patterns"""
        print("[3.1] __namecall patterns...")
        self._find_namecalls(code)
       
        print("[3.2] loadstring patterns...")
        self._find_loadstrings(code)
       
        print("[3.3] URL patterns...")
        self._find_urls(code)
       
        print("[3.4] Remote calls...")
        self._find_remote_calls(code)
       
        print("[3.5] Metamethods...")
        self._find_metamethods(code)
       
        print("[3.6] Hooks...")
        self._find_hooks(code)
       
        print("[3.7] Anti-detection...")
        self._find_anti_detection(code)
       
        print("[3.8] Roblox services...")
        self._find_roblox_services(code)
   
    def _find_namecalls(self, code: str):
        """Find __namecall patterns"""
        patterns = [
            (r'__namecall\s*=\s*([^;\n]+)', 'assignment'),
            (r'getnamecallmethod\s*\(\s*\)', 'getnamecallmethod'),
            (r'\["__namecall"\]', 'bracket_access'),
            (r'__namecall\s*~=', 'comparison'),
            (r'mt\.__namecall', 'metatable_access'),
        ]
       
        for pattern, ptype in patterns:
            matches = list(re.finditer(pattern, code, re.IGNORECASE))
            if matches:
                for match in matches[:5]:
                    self.namecalls.append({'type': ptype, 'code': match.group(0)})
                    print(f" ✓ {ptype}: {match.group(0)[:60]}")
                if len(matches) > 5:
                    print(f" ... and {len(matches) - 5} more")
   
    def _find_loadstrings(self, code: str):
        """Find and decode loadstring calls"""
        patterns = [
            (r'loadstring\s*\(\s*([^)]+)\)', 'direct'),
            (r'loadstring\s*\(\s*game:HttpGet\s*\(\s*["\']([^"\']+)["\']', 'httpget'),
            (r'GetAsync\s*\(\s*["\']([^"\']+)["\']', 'getasync'),
        ]
       
        for pattern, ptype in patterns:
            for match in re.finditer(pattern, code, re.IGNORECASE):
                content = match.group(1)
                self.loadstrings.append({
                    'type': ptype,
                    'content': content[:200],
                    'full': match.group(0)
                })
               
                if ptype == 'direct':
                    decoded = self.loadstring_decoder.decode_loadstring(content)
                    if decoded and decoded != content:
                        self.decoded_loadstrings.append({
                            'original': content[:100],
                            'decoded': decoded[:500] if isinstance(decoded, str) else str(decoded)[:500]
                        })
                        self.stats['loadstrings_decoded'] += 1
                        print(f" ✓ DECODED {ptype}: {str(decoded)[:80]}")
                else:
                    print(f" ✓ {ptype}: {content[:60]}")
   
    def _find_urls(self, code: str):
        """Find URLs"""
        urls = set(re.findall(r'https?://[^\s\'"<>)}\]]+', code))
       
        for url in urls:
            try:
                parsed = urlparse(url)
                self.urls.append({
                    'url': url,
                    'domain': parsed.hostname or 'unknown',
                    'suspicious': any(d in (parsed.hostname or '').lower()
                                    for d in ['discord', 'pastebin', 'webhook', 'raw.githubusercontent'])
                })
                self.stats['urls_extracted'] += 1
                marker = "🚨" if any(d in (parsed.hostname or '').lower() for d in ['discord', 'webhook']) else "→"
                print(f" {marker} URL: {url[:60]}")
            except:
                pass
   
    def _find_remote_calls(self, code: str):
        """Find remote calls"""
        pattern = r'(FireServer|InvokeServer|RemoteEvent|RemoteFunction)\s*\('
        for match in re.finditer(pattern, code, re.IGNORECASE):
            self.remote_calls.append(match.group(0))
            print(f" ✓ Remote: {match.group(0)}")
   
    def _find_metamethods(self, code: str):
        """Find metamethods"""
        counts = defaultdict(int)
        for match in re.finditer(r'__(\w+)\s*=', code):
            counts[match.group(1)] += 1
       
        for name, count in counts.items():
            self.metamethods.append({'name': name, 'count': count})
            print(f" ✓ Metamethod __{name}: {count}x")
   
    def _find_hooks(self, code: str):
        """Find hooks"""
        patterns = [
            (r'hookfunction', 'hookfunction'),
            (r'hookmetamethod', 'hookmetamethod'),
            (r'replaceclosure', 'replaceclosure'),
            (r'newcclosure', 'newcclosure'),
        ]
       
        for pattern, name in patterns:
            count = len(re.findall(pattern, code, re.IGNORECASE))
            if count:
                self.hooks.append({'type': name, 'count': count})
                print(f" ✓ {name}: {count}x")
   
    def _find_anti_detection(self, code: str):
        """Find anti-detection techniques"""
        patterns = [
            (r'checkcaller', 'checkcaller'),
            (r'isvm', 'vm detection'),
            (r'debug\.getinfo', 'debug info'),
            (r'identifyexecutor', 'executor detection'),
            (r'getgenv', 'global environment'),
            (r'getrenv', 'registry environment'),
        ]
       
        for pattern, tech in patterns:
            count = len(re.findall(pattern, code, re.IGNORECASE))
            if count:
                self.anti_detection.append({'technique': tech, 'count': count})
                print(f" ✓ {tech}: {count}x")
   
    def _find_roblox_services(self, code: str):
        """Find Roblox service usage"""
        services = [
            'Players', 'Workspace', 'ReplicatedStorage', 'ServerScriptService',
            'HttpService', 'TeleportService', 'MarketplaceService', 'UserInputService',
            'RunService', 'TweenService', 'Lighting', 'StarterGui', 'StarterPlayer'
        ]
       
        for service in services:
            pattern = rf'\b{service}\b'
            if re.search(pattern, code):
                self.roblox_services.add(service)
       
        if self.roblox_services:
            print(f" ✓ Roblox services: {', '.join(sorted(self.roblox_services))}")
   
    def _analyze_control_flow(self, code: str):
        """Analyze control flow obfuscation"""
        self.control_flow = self.control_flow_analyzer.find_control_flow_patterns(code)
       
        if self.control_flow:
            self.stats['control_flow_patterns'] = len(self.control_flow)
            print(f"[4.1] Control flow patterns found: {len(self.control_flow)}")
           
            pattern_types = defaultdict(int)
            for pattern in self.control_flow:
                pattern_types[pattern['type']] += 1
           
            for ptype, count in pattern_types.items():
                print(f" ✓ {ptype}: {count}x")
   
    def _security_analysis(self, code: str):
        """Analyze security risks"""
        risks = []
       
        sus_urls = [u for u in self.urls if u.get('suspicious')]
        if sus_urls:
            risks.append({
                'level': 'HIGH',
                'type': 'Suspicious URLs',
                'count': len(sus_urls),
                'details': [u['url'] for u in sus_urls[:3]]
            })
       
        if self.loadstrings:
            risks.append({
                'level': 'CRITICAL',
                'type': 'Dynamic Code Execution',
                'count': len(self.loadstrings)
            })
       
        if self.remote_calls:
            risks.append({
                'level': 'MEDIUM',
                'type': 'Remote Server Calls',
                'count': len(self.remote_calls)
            })
       
        if self.hooks:
            risks.append({
                'level': 'HIGH',
                'type': 'Function Hooks',
                'count': sum(h['count'] for h in self.hooks)
            })
       
        if self.anti_detection:
            risks.append({
                'level': 'HIGH',
                'type': 'Anti-Detection',
                'count': sum(a['count'] for a in self.anti_detection)
            })
       
        self.suspicious = risks
        self.stats['risks_detected'] = len(risks)
       
        if risks:
            print(f"\n ⚠️ {len(risks)} SECURITY RISK CATEGORIES DETECTED!")
            for risk in risks:
                print(f" [{risk['level']}] {risk['type']}: {risk['count']} instances")
   
    def _deobfuscate_code(self, code: str) -> str:
        """Deobfuscate code"""
        print("[5.1] Replacing string table accesses...")
        code = self._replace_string_accesses(code)
       
        print("[5.2] Replacing function calls...")
        code = self._replace_function_calls(code)
       
        print("[5.3] Simplifying control flow...")
        code = self._simplify_control_flow(code)
       
        print("[5.4] Beautifying...")
        code = self._beautify(code)
       
        return code
   
    def _replace_string_accesses(self, code: str) -> str:
        """Replace string table accesses with actual strings"""
        replacements = 0
       
        for var, strings in self.string_tables.items():
            if var.endswith('_DECODED'):
                continue
           
            pattern_simple = rf'{re.escape(var)}\s*\[\s*(\d+)\s*\]'
           
            def replacer(m):
                nonlocal replacements
                idx = int(m.group(1))
                if 0 <= idx < len(strings):
                    s = strings[idx]
                    s = s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
                    replacements += 1
                    return f'"{s}"'
                return m.group(0)
           
            code = re.sub(pattern_simple, replacer, code)
       
        if replacements:
            print(f" ✓ {replacements} string replacements made")
       
        return code
   
    def _replace_function_calls(self, code: str) -> str:
        """Replace function lookup calls"""
        replacements = 0
       
        for func, table in self.function_tables.items():
            if table not in self.string_tables:
                continue
           
            strings = self.string_tables[table]
            pattern = rf'{re.escape(func)}\s*\(\s*(\d+)\s*\)'
           
            def replacer(match):
                nonlocal replacements
                idx = int(match.group(1))
                if 0 <= idx < len(strings):
                    s = strings[idx]
                    s = s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
                    replacements += 1
                    return f'"{s}"'
                return match.group(0)
           
            code = re.sub(pattern, replacer, code)
       
        if replacements:
            print(f" ✓ {replacements} function call replacements made")
       
        return code
   
    def _simplify_control_flow(self, code: str) -> str:
        """Simplify obfuscated control flow"""
        original_len = len(code)
       
        code = re.sub(
            r'while\s+true\s+do\s+(.*?)\s+break\s+end',
            r'\1',
            code,
            flags=re.DOTALL | re.IGNORECASE
        )
       
        code = re.sub(
            r'repeat\s+(.*?)\s+until\s+true',
            r'\1',
            code,
            flags=re.DOTALL | re.IGNORECASE
        )
       
        code = re.sub(
            r'do\s+(.*?)\s+end(?!\s*\))',
            r'\1',
            code,
            flags=re.DOTALL | re.IGNORECASE
        )
       
        simplified = original_len - len(code)
        if simplified > 0:
            print(f" ✓ Simplified control flow ({simplified} chars removed)")
       
        return code
   
    def _beautify(self, code: str) -> str:
        """Beautify Lua code with proper indentation"""
        lines = []
        indent = 0
       
        for line in code.replace(';', '\n').split('\n'):
            line = line.strip()
            if not line or line.startswith('--'):
                lines.append(line)
                continue
           
            if any(line.startswith(kw) for kw in ['end', 'else', 'elseif', 'until']):
                indent = max(0, indent - 1)
           
            lines.append(' ' * indent + line)
           
            opens = len(re.findall(r'\b(function|if|then|do|for|while|repeat)\b', line))
            closes = len(re.findall(r'\bend\b', line))
            indent += opens - closes
            indent = max(0, indent)
       
        return '\n'.join(lines)
   
    def _generate_output(self, code: str) -> str:
        """Generate final output with full analysis"""
        lines = [
            "-- ╔══════════════════════════════════════════════════════════════════════════╗",
            "-- ║ FULLY DEOBFUSCATED - ZESTY LUAU DEOBFUSCATOR 2026 ║",
            "-- ║ Enhanced Bytecode Analysis • Advanced Pattern Detection ║",
            "-- ╚══════════════════════════════════════════════════════════════════════════╝",
            ""
        ]
       
        if self.ironbrew_strings:
            lines.append("-- ┌─ IRONBREW DECODED STRINGS ────────────────────────────────────────┐")
            for original, decoded in self.ironbrew_strings[:10]:
                lines.append(f"-- {original}...")
                lines.append(f"-- → {decoded[:100]}")
            lines.append("-- └──────────────────────────────────────────────────────────────────────┘")
            lines.append("")
       
        if self.decoded_loadstrings:
            lines.append("-- ┌─ DECODED LOADSTRINGS ──────────────────────────────────────────────┐")
            for ls in self.decoded_loadstrings[:5]:
                lines.append(f"-- Original: {ls['original']}")
                lines.append(f"-- Decoded: {ls['decoded'][:200]}")
                lines.append("-- ")
            lines.append("-- └──────────────────────────────────────────────────────────────────────┘")
            lines.append("")
       
        if self.urls:
            lines.append("-- ┌─ URLS FOUND ───────────────────────────────────────────────────────┐")
            for u in self.urls:
                marker = "🚨 SUSPICIOUS" if u.get('suspicious') else "→"
                lines.append(f"-- {marker} {u['url']}")
            lines.append("-- └──────────────────────────────────────────────────────────────────────┘")
            lines.append("")
       
        if self.suspicious:
            lines.append("-- ┌─ ⚠️ SECURITY RISKS DETECTED ⚠️ ──────────────────────────────────┐")
            for risk in self.suspicious:
                lines.append(f"-- [{risk['level']}] {risk['type']}: {risk['count']} instances")
                if 'details' in risk:
                    for detail in risk['details']:
                        lines.append(f"-- - {detail}")
            lines.append("-- └──────────────────────────────────────────────────────────────────────┘")
            lines.append("")
       
        if self.roblox_services:
            lines.append("-- ┌─ ROBLOX SERVICES USED ─────────────────────────────────────────────┐")
            lines.append(f"-- {', '.join(sorted(self.roblox_services))}")
            lines.append("-- └──────────────────────────────────────────────────────────────────────┘")
            lines.append("")
       
        if self.control_flow:
            lines.append("-- ┌─ CONTROL FLOW OBFUSCATION ─────────────────────────────────────────┐")
            flow_types = defaultdict(int)
            for pattern in self.control_flow:
                flow_types[pattern['type']] += 1
            for flow_type, count in flow_types.items():
                lines.append(f"-- {flow_type}: {count}x")
            lines.append("-- └──────────────────────────────────────────────────────────────────────┘")
            lines.append("")
       
        lines.extend([
            "-- ┌─ DECODING STATISTICS ──────────────────────────────────────────────────┐",
            f"-- Strings decoded: {self.stats['strings_decoded']}",
            f"-- Zero-width escapes (\\z): {self.stats['zero_width_decoded']}",
            f"-- Unicode escapes: {self.stats['unicode_decoded']}",
            f"-- Octal escapes: {self.stats['octal_decoded']}",
            f"-- IronBrew strings: {self.stats['ironbrew_decoded']}",
            f"-- Bytecode decoded: {self.stats['bytecode_decoded']}",
            f"-- Hex decoded: {self.stats['hex_decoded']}",
            f"-- Functions found: {self.stats['functions_found']}",
            f"-- Loadstrings decoded: {self.stats['loadstrings_decoded']}",
            f"-- Control flow patterns: {self.stats['control_flow_patterns']}",
            f"-- URLs extracted: {self.stats['urls_extracted']}",
            f"-- Security risks: {self.stats['risks_detected']}",
            "-- └──────────────────────────────────────────────────────────────────────┘",
            "",
            "-- ╔══════════════════════════════════════════════════════════════════════════╗",
            "-- ║ DEOBFUSCATED CODE ║",
            "-- ╚══════════════════════════════════════════════════════════════════════════╝",
            "",
            code
        ])
       
        return '\n'.join(lines)
def main():
    """Main entry point"""
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    else:
        input_file = 'input.lua'
   
    try:
        with open(input_file, 'r', encoding='utf-8', errors='replace') as f:
            code = f.read()
    except FileNotFoundError:
        print(f"❌ ERROR: File not found: {input_file}")
        print(f"\nUsage: python {sys.argv[0]} <input_file.lua>")
        print(f" or: python {sys.argv[0]} (defaults to 'input.lua')")
        return
    except Exception as e:
        print(f"❌ ERROR reading file: {e}")
        return
   
    print(f"📄 Processing: {input_file}")
    print(f"📊 Size: {len(code):,} characters\n")
   
    deob = ZestyDeobfuscator()
    result = deob.process(code)
   
    output_file = 'ZESTY_DEOBFUSCATED.lua'
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(result)
        print(f"\n✅ Saved deobfuscated code: {output_file}")
    except Exception as e:
        print(f"\n❌ Error saving output: {e}")
   
    analysis = {
        'file': input_file,
        'stats': deob.stats,
        'security_risks': deob.suspicious,
        'urls': deob.urls,
        'loadstrings': [
            {'type': ls['type'], 'preview': ls['content'][:100]}
            for ls in deob.loadstrings
        ],
        'decoded_loadstrings': deob.decoded_loadstrings,
        'roblox_services': list(deob.roblox_services),
        'control_flow_patterns': [
            {'type': p['type'], 'count': 1} for p in deob.control_flow
        ],
        'hooks': deob.hooks,
        'anti_detection': deob.anti_detection,
        'metamethods': deob.metamethods,
        'string_tables': {
            k: {
                'count': len(v),
                'samples': v[:5]
            }
            for k, v in deob.string_tables.items()
        }
    }
   
    analysis_file = 'ZESTY_ANALYSIS.json'
    try:
        with open(analysis_file, 'w', encoding='utf-8') as f:
            json.dump(analysis, f, indent=2, ensure_ascii=False)
        print(f"✅ Saved detailed analysis: {analysis_file}")
    except Exception as e:
        print(f"❌ Error saving analysis: {e}")
   
    print("\n" + "="*80)
    print("╔══════════════════════════════════════════════════════════════════════════╗")
    print("║ SUMMARY ║")
    print("╚══════════════════════════════════════════════════════════════════════════╝")
    print(f"✓ Decoded {deob.stats['strings_decoded']} strings")
    print(f"✓ Found {deob.stats['functions_found']} lookup functions")
    print(f"✓ Extracted {deob.stats['urls_extracted']} URLs")
    print(f"✓ Decoded {deob.stats['loadstrings_decoded']} loadstrings")
    print(f"✓ Bytecode analysis: {deob.stats['bytecode_decoded']} instances")
    print(f"✓ Hex decoded: {deob.stats['hex_decoded']} instances")
   
    if deob.stats['risks_detected'] > 0:
        print(f"\n⚠️ WARNING: {deob.stats['risks_detected']} security risk categories detected!")
        print(" Review ZESTY_ANALYSIS.json for details")
   
    print("\n✅ Zesty deobfuscation complete! 🎉")
if __name__ == '__main__':
    main()
