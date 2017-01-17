/* Copyright 2014-2017 Gregor Uhlenheuer
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#pragma once

#include "nyx.h"

#include <stdbool.h>
#include <stdint.h>

typedef struct
{
    int32_t id;
    bool start;
} fork_info_t;

int32_t
forker_init(nyx_t *nyx);

fork_info_t *
forker_start(int32_t id);

fork_info_t *
forker_stop(int32_t id);

/* vim: set et sw=4 sts=4 tw=80: */
